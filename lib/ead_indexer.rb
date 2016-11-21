require "solr_ead"
require 'iso-639'
require "ead_indexer/engine"
require "ead_indexer/behaviors/component"
require "ead_indexer/behaviors/dates"
require "ead_indexer/behaviors/document"
require "ead_indexer/behaviors"
require "ead_indexer/component"
require "ead_indexer/document"
require "ead_indexer/indexer"

module EadIndexer
  extend ActiveSupport::Autoload

  autoload :Behaviors
  autoload :Document
  autoload :Component
  autoload :Indexer
end
