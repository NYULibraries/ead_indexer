require 'ead_indexer'

namespace :ead_indexer do

  desc "Index ead into solr using EAD=<FILE|DIR>"
  task :index => :environment do
    ENV['EAD'] = "spec/fixtures/ead" unless ENV['EAD']
    indexer = EadIndexer::Indexer.new
    indexer.index(ENV['EAD'])
  end

  desc "Reindex only the files in the data repository that have changed since the last commit"
  task :reindex_changed => :environment do
    indexer = EadIndexer::Indexer.new
    indexer.reindex_changed_since_last_commit
  end

  desc "Reindex only the files in the data repository that have changed since yesterday"
  task :reindex_changed_since_yesterday => :environment do
    indexer = EadIndexer::Indexer.new
    indexer.reindex_changed_since_yesterday
  end

  desc "Reindex only the files in the data repository that have changed since last week"
  task :reindex_changed_since_last_week => :environment do
    indexer = EadIndexer::Indexer.new
    indexer.reindex_changed_since_last_week
  end

  # e.g., rake findingaids:ead:reindex_changed_since_days_ago[20]
  desc "Reindex only the files in the data repository that have changed since [days] days ago"
  task :reindex_changed_since_days_ago, [:days] => :environment do |_, args|
    indexer = EadIndexer::Indexer.new
    indexer.reindex_changed_since_days_ago(args.days)
  end

  desc "Deletes everything from the solr index"
  task :clean => :environment do
    EadIndexer::Indexer.delete_all
  end

end
