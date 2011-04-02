class Message 
  include MongoMapper::Document
  
  key :body, String, :required => true
	key :ip, String
	timestamps!
end