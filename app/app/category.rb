class Category < NanoStore::Model
  attribute :name
  bag :articles
end
