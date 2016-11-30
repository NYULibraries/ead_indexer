class EadIndexer::Configuration
  attr_accessor :document_class, :component_class

  def initialize
    @document_class = EadIndexer::Document
    @component_class = EadIndexer::Component
  end
end
