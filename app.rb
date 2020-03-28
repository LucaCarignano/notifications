class App < Sinatra::Base
    	get "/" do
        	"hello cruel world!!!"
    	end
    	get "/users" do
        	"hello users"
	end
	get "/admin" do
		"hello admins"
	end
	get "/documents" do
		"no documents yet"
	end
end
