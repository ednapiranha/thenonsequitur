get "/" do
 redirect "/index/"
end

not_found do
  status 404
end