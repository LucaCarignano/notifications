class App < Sinatra::Base
    	get "/" do
        	erb :log 
    	end
    	post "/" do
    		if params[:user]=="Fede" && params[:pass] == "LUCA"
				    "funciona"
			else erb :log 			
    		end
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
