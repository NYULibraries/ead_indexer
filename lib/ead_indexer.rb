require "rake"
require "solr_ead"
require 'iso-639'
require "ead_indexer/engine"
require "ead_indexer/behaviors/component"
require "ead_indexer/behaviors/dates"
require "ead_indexer/behaviors/document"
require "ead_indexer/behaviors"
require "ead_indexer/component"
require "ead_indexer/configuration"
require "ead_indexer/document"
require "ead_indexer/indexer"
require "ead_indexer/prom_metrics"

module EadIndexer
  extend ActiveSupport::Autoload

  autoload :Behaviors
  autoload :Document
  autoload :Component
  autoload :Configuration
  autoload :Indexer
  autoload :PromMetrics

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(self.configuration)
  end
end
