get "/stylesheets/main.css" do
  content_type 'text/css'
	response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
  sass :"stylesheets/main"
end

get '/index/' do
	@messages = Message.sort(:created_at.desc).limit(150).all
	haml :index
end

post '/create' do
	if params[:email].blank?
		body = []
		tags = []
		params[:body].to_s.split(/\s/).each { |w| 
			tag = Tag.first(:name => clean(w))
			if is_valid(w)
				tag.blank? ? Tag.create(:name => clean(w)) : tag.update_attributes({ :total_count => tag.total_count + 1 })
				body << "<a href='/tags/#{clean(w)}'>#{soft_clean(w)}</a>"
				tags << clean(w)
			else
				body << soft_clean(w)
			end
		}.join(" ")
		
		@message = Message.create(:body => body.join(" "), :ip => request.env['REMOTE_ADDR'], :tags => tags)
		if params[:parent_id]
			parent_message = Message.first(:id => params[:parent_id])
			if parent_message
				@message.update_attributes({ :parent_id => parent_message.id })
				parent_message.update_attributes({ :vote_count => parent_message.vote_count + 1 })
				redirect "/post/#{parent_message.id}"
			end
		end
	end
	@messages = Message.sort(:created_at.desc).limit(150).all
	haml :index
end
=begin
get '/delete' do
	Message.delete_all
	Tag.delete_all
	redirect '/'
end
=end

get '/post/vote/:id' do
	message = Message.first(:id => params[:id])
	message.update_attributes({ :vote_count => message.vote_count + 1 })
	return true
end

get '/post/:id' do
	@messages = [Message.first(:id => params[:id])]
	@replies = Message.where(:parent_id => params[:id]).sort(:created_at.desc).all
	@single_view = true
	haml :index
end

get '/tagfix' do
	@tags = Tag.all
	@tags.each { |t| t.delete if !is_valid(t.name) }
end

get '/unlink/:word' do
	@messages = Message.all
	@messages.each { |m| 
		m.update_attributes({ :body => m.body.gsub(/(<a href='\/tags\/#{params[:word]}'>#{params[:word]}<\/a>)/, params[:word]) })
	}
	redirect '/'
end

get '/tags/:word' do
	@messages = Message.where(:tags => params[:word].to_s.downcase).sort(:created_at.desc).all
	haml :index
end

get '/popular/tags' do
	@tags = Tag.where(:total_count.gt => 1).sort(:total_count.desc).limit(100).all
	haml :popular
end

get '/popular/posts' do
	@messages = Message.where(:vote_count.gt => 1).sort(:vote_count.desc).limit(100).all
	haml :index
end
