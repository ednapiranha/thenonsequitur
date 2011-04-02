get "/stylesheets/main.css" do
  content_type 'text/css'
	response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
  sass :"stylesheets/main"
end

get '/index/' do
	@messages = Message.sort(:created_at.desc).all
	haml :index
end

post '/create' do
	if params[:email].blank?
		body = []
		tags = []
		params[:body].to_s.split(/\s/).each { |w| 
			tags << clean(w)
			is_valid(w) ? body << "<a href='/tags/#{clean(w)}'>#{soft_clean(w)}</a>" : body << soft_clean(w)
		}.join(" ")
		@message = Message.create(:body => body.join(" "), :ip => request.env['REMOTE_ADDR'], :tags => tags)
	end
	@messages = Message.sort(:created_at.desc).all
	haml :index
end

get '/delete' do
	Message.delete_all
	redirect '/'
end

get '/tags/:word' do
	@messages = Message.where(:tags => params[:word].to_s.downcase).sort(:created_at.desc).all
	haml :index
end
