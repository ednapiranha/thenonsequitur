get "/stylesheets/main.css" do
  content_type 'text/css'
	response['Expires'] = (Time.now + 60*60*24*356*3).httpdate
  sass :"stylesheets/main"
end

get '/index/' do
	Message.delete_all
	@messages = Message.sort(:created_at.desc).all
	haml :index
end

post '/create' do
	if params[:email].blank?
		@message = Message.create(:body => params[:body], :ip => request.env['REMOTE_ADDR'])
	end
	@messages = Message.sort(:created_at.desc).all
	haml :index
end
