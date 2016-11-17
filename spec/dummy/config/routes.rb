Rails.application.routes.draw do

  mount EadIndexer::Engine => "/ead_indexer"
end
