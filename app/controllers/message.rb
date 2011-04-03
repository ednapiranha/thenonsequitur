get "/stylesheets/main.css" do
  content_type 'text/css'
	response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
  sass :"stylesheets/main"
end

get '/index/' do
	@messages = Message.sort(:created_at.desc).limit(100).all
	haml :index
end

post '/create' do
	if params[:email].blank?
		body = []
		tags = []
		params[:body].to_s.split(/\s/).each { |w| 
			tags << clean(w)
			tag = Tag.first(:name => clean(w))
			tag.blank? and is_valid(w) ? Tag.create(:name => clean(w)) : tag.update_attributes({ :total_count => tag.total_count + 1 })
			is_valid(w) ? body << "<a href='/tags/#{clean(w)}'>#{soft_clean(w)}</a>" : body << soft_clean(w)
		}.join(" ")

		@message = Message.create(:body => body.join(" "), :ip => request.env['REMOTE_ADDR'], :tags => tags)
	end
	@messages = Message.sort(:created_at.desc).limit(100).all
	haml :index
end
=begin
get '/delete' do
	Message.delete_all
	Tag.delete_all
	redirect '/'
end
=end

get '/post/:id' do
	@messages = [Message.first(:id => params[:id])]
	haml :index
end

get '/tagfix' do
	@tags = Tag.all
	@tags.each { |t| t.delete if !is_valid(t.name) }
end

get '/unlink/:word' do
	@messages = Message.all
	@messages.each { |m| 
		m.update_attributes({ :body => m.body.gsub(/(<a href="\/tags\/#{params[:word]}">\1<\/a>)/, params[:word]) })
	}
	redirect '/'
end

get '/tags/:word' do
	@messages = Message.where(:tags => params[:word].to_s.downcase).sort(:created_at.desc).all
	haml :index
end

get '/popular' do
	@tags = Tag.sort(:total_count.desc).limit(100).all
	haml :popular
end
