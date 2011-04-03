class Tag
  include MongoMapper::Document
  
  key :name, String
	key :total_count, Integer, :default => 1

	validates_presence_of :name
end