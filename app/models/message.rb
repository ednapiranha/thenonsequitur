class Message 
  include MongoMapper::Document
  
  key :body, String, :required => true
	key :ip, String
	key :tags, Array
	key :vote_count, Integer, :default => 0
	key :parent_id, String
	timestamps!
	
	def reply_total
		Message.count(:parent_id => self.id.to_s)
	end
end