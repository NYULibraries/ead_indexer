require 'prometheus/client'
require 'prometheus/client/push'

require 'solr_ead'
require 'fileutils'
##
# Ead Indexer
#
# This class will index a file or directory into a Solr index configured via blacklight.yml
# It essentially wraps the functionality of SolrEad::Indexer with some customizations
# mainly the ability to index directories and reindex changed files from a Git diff.
#
# The #index function takes in a file or directory and calls update on all the valid .xml files it finds.
# The #reindex_changed_since_last_commit function finds all the files changed since the previous commit and updates, adds or deletes accordingly.
# The #reindex_changed_since_yesterday function finds all the files changed since yesterday and updates, adds or deletes accordingly.
# The #reindex_changed_since_last_week function finds all the files changed since last week and updates, adds or deletes accordingly.
# The .delete_all convenience method wraps Blacklight.default_index.connection to easily clear the index
class EadIndexer::Indexer

  def self.delete_all
    Blacklight.default_index.connection.tap do |solr|
      solr.delete_by_query("*:*")
      solr.commit
    end
  end

  attr_accessor :indexer, :data_path, :prom_metrics

  def initialize(data_path="findingaids_eads")
    @data_path = data_path
    @indexer = SolrEad::Indexer.new(document: EadIndexer.configuration.document_class, component: EadIndexer.configuration.component_class)
    @prom_metrics = init_prom_metrics('git-trigger')
  end

  def index(file)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    unless File.directory?(file)
      update(file)
    else
      updated_files = []
      Dir.glob(File.join(file,"*")).each do |dir_file|
        updated_files << update(dir_file)
      end
      updated_files.all?
    end
  end

  # Reindex files changed only since the last commit
  def reindex_changed_since_last_commit
    @prom_metrics = init_prom_metrics('git-trigger')
    prom_metrics&.register_metrics!
    begin
      reindex_changed(commits)
    ensure
      prom_metrics&.push_metrics!
    end
  end

  # Reindex all files changed in the last day
  def reindex_changed_since_yesterday
    @prom_metrics = init_prom_metrics('nightly')
    begin
      reindex_changed(commits('--since=1.day'))
    ensure
      prom_metrics&.push_metrics!
    end
  end

  # Reindex all files changed in the last week
  def reindex_changed_since_last_week
    @prom_metrics = init_prom_metrics('weekly')
    begin
      reindex_changed(commits('--since=1.week'))
    ensure
      prom_metrics&.push_metrics!
    end
  end

  # Reindex all files changed since x days ago
  def reindex_changed_since_days_ago(days_ago)
    @prom_metrics = init_prom_metrics('x-days')
    # assert that argument can be converted to an integer
    days = Integer(days_ago)
    begin
      reindex_changed(commits("--since=#{days}.day"))
    ensure
      prom_metrics&.push_metrics!
    end
  end

private

  # Reindex files changed in list of commit SHAs
  def reindex_changed(last_commits)
    updated_files = []
    changed_files(last_commits).each do |file|
      status, filename, message = file.split("\t")
      fullpath = File.join(data_path, filename)
      updated_files << update_or_delete(status, fullpath, message)
      # sleep for rate limiting https://docs.websolr.com/article/178-http-429-too-many-requests
      sleep ENV['FINDINGAIDS_RAKE_INDEX_SLEEP_INTERVAL'].to_i if ENV['FINDINGAIDS_RAKE_INDEX_SLEEP_INTERVAL']
    end
    if updated_files.empty?
      log.info "No files to index."
      puts "No files to index."
    end
    # Return true is all the files were sucessfully updated
    # or if there were no files
    (updated_files.all? || updated_files.empty?)
  end

  # TODO: Make time range configurable by instance variable
  #       and cascade through to rake jobs

  # Get the sha for the time range given
  #
  # time_range    git option to get set of results based on a date/time range;
  #               default is -1, just the last commit
  def commits(time_range = '-1')
    @commits ||= `cd #{data_path} && git log --pretty=format:'%h' #{time_range} && cd ..`.split("\n")
  end

  # Get list of files changed since last commit
  def changed_files(last_commits)
    changed_files = []
    last_commits.each do |commit|
      files_in_commit = (`cd #{data_path} && git diff-tree --no-commit-id --name-status -r #{commit} && cd ..`).split("\n")
      commit_message = (`cd #{data_path} && git log --pretty=format:'%s' -1 -c #{commit} && cd ..`).gsub(/(\n+)$/,'')
      files_in_commit.each do |changed_file|
        changed_files << [changed_file, commit_message].join("\t")
      end
    end
    changed_files.flatten
  end

  # Update or delete depending on git status
  def update_or_delete(status, file, message)
    eadid = get_eadid_from_message(file, message)
    # Only reindex for XML files
    if File.exist?(file)
      update(file)
    # Status == D means the file was deleted
    elsif status.eql? "D"
      delete(file, eadid)
    end
  end

  def get_eadid_from_message(file, message)
    # Strip out initial folder name to match filename in commit message
    file_without_data_path = file.gsub(/#{data_path}(\/)?/,'')
    eadid_matches = message.match(/#{file_without_data_path} EADID='(.+?)'/)
    eadid_matches.captures.first unless eadid_matches.nil?
  end

  # Wrapper method for SolrEad::Indexer#update(file)
  # => @file      filename of EAD
  def update(file)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    if /\.xml$/.match(file).present?
      begin
        # The document is built around a repository that relies on the folder structure
        # since it does not exist consistently in the EAD, so we pass in the full path to extract the repos.
        ENV["EAD"] = file
        indexer.update(file)
        record_success("Indexed #{file}.", { action: 'update' })
      rescue StandardError => e
        record_failure("Failed to index #{file}: #{e}.", { action: 'update', ead: file })
        raise e
      end
    else
      record_failure("Failed to index #{file}: not an XML file.", { action: 'update', ead: file })
    end
  end

  # Wrapper method for SolrEad::Indexer#delete
  # => @id        EAD id
  def delete(file, eadid)
    if file.blank?
      raise ArgumentError.new("Expecting #{file} to be a file or directory")
    end
    if /\.xml$/.match(file).present?
      # If eadid was passed in, use it to delete
      # it not, make a guess based on filename
      id = (eadid || File.basename(file).split("\.")[0])
      begin
        indexer.delete(id)
        record_success("Deleted #{file} with id #{id}.", { action: 'delete' })
      rescue StandardError => e
        record_failure("Failed to delete #{file} with id #{id}: #{e}", { action: 'delete', ead: file })
        raise e
      end
    else
      record_failure("Failed to delete #{file}: not an XML file.", { action: 'delete', ead: file })
    end
  end

  # Set FINDINGAIDS_LOG=STDOUT to view logs in standard out
  def log
    @log ||= (ENV['FINDINGAIDS_LOG']) ? Logger.new(ENV['FINDINGAIDS_LOG'].constantize) : Rails.logger
  end

  def record_success(msg, labels={})
    metric_labels = prom_metrics&.default_labels&.merge(labels)
    puts "#{msg}"
    log.info "#{msg}."
    prom_metrics&.success_counter&.increment(labels: metric_labels)
    true
  end

  def record_failure(msg, labels={})
    metric_labels = prom_metrics&.default_labels&.merge(labels)
    puts "#{msg}"
    log.info "#{msg}."
    prom_metrics&.failure_counter&.increment(labels: metric_labels)
    false
  end

  def init_prom_metrics(cronjob)
    EadIndexer::PromMetrics.new('specialcollections', cronjob) if ENV['PROM_PUSHGATEWAY_URL']
  end

end
