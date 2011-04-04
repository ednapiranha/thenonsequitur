class Message 
  include MongoMapper::Document
  
  key :body, String, :required => true
	key :ip, String
	key :tags, Array
	key :vote_count, Integer, :default => 0
	timestamps!
	
end