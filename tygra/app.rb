require "sinatra"

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  [username, password] == ['admin', 'admin']
end

get "/" do
     "Hello! I'm tygra."
     end
not_found do
     status 404
     "Something wrong! Try to type URL correctly or call to UFO."
end

get '/test1.txt' do
  "Hello World"
end