class App < Sinatra::Base
	
	get "/" do
    	erb :log
	end

	#Comprobar que el usuario y la contraseña sean del mismo user y se encuentre en
	#la base de datos, si no, informar que se han ingresado datos inválidos
	post "/" do
		if params[:user]=="asd" && params[:pass] == "asd" 
			    "funciona"
		else 
			@error = 'Username or password was incorrect'
     		erb :log			
		end
	end

	#Comprobar que el usuario y la contraseña sean del mismo user y se encuentre en la base de datos
	#post "/" do
	#	if params[:users]=="asd" || params[:passs] == "asd" 
	#		    "funciona"
	#	else erb :login
	#	end
	#end

	get "/rp" do
		erb :rp
	end
	
	#Comprobar que el mail se encuentre en la base de datos
	post "/rp" do
		if params[:email]=="Fede@gmail" 
			    "se a enviado un correo a tu mail con la nueva contraseña provisoria"
		else "email inválido"
		end
	end
end
