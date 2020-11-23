require './exceptions/ValidationModelError.rb'
require './models/user.rb'

class UserService
  #def all_field_register?
    #username.empty? or password.empty? or name.empty? or email.empty? or surname.empty?
  #end

	def self.registerUser(name, surname, email, username, password, password2)
		if username.empty? or password.empty? or name.empty? or email.empty? or surname.empty? 
      raise ArgumentError.new("Complete todos los campos")
    end
    if password != password2
      raise ArgumentError.new("Las contraseñas no coinciden")
    end
    user = User.new(name: name,
                      surname: surname,
                      email: email,
                      username: username,
                      password: password)
    unless user.valid?
      raise ValidationModelError.new("Datos para crear el usuario incorrectos", user.errors)
    end
    user.save
	end



	#def self.modifyUser(params)
	#	#######
	#end
end