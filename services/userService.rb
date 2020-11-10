require './exceptions/ValidationModelError.rb'
require './models/user.rb'

class Account_service
	def self.registerUser(name, surname, email, username, password, password2)
		if username == nil or password == nil or password_repeat == nil
      raise ArgumentError.new("Complete todos los campos")
    end
    if password != password2
      raise ArgumentError.new("Las contraseñas no coinciden")
    end
    user = User.new(name: params['name'],
                      surname: params['surname'],
                      email: params['email'],
                      username: params['username'],
                      password: params['password'])
    unless user.valid?
      raise ValidationModelError.new("Datos para crear el usuario incorrectos", user.errors)
    end
    user.save
	end

	#def self.modifyUser(params)
	#	#######
	#end
end