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

  def self.view_noti(user)
    if user
      id = Labelled.select(:document_id).where(readed: 'f', user_id: user.id)
      return Document.where(delete: 'f', id: id).count
    end
  end

	def self.modifyUser(user, editusername, editemail, editpass, 
                      botusername, botemail, botpass, newusername, 
                      newemail, newpass, repass, oldpass)
    if editusername
      newpass = user.password
      newemail = user.email
    elsif editemail
      newpass = user.password
      newusername = user.username
    elsif editpass
      if newpass.empty? or repass.empty? or oldpass.empty?
        raise ArgumentError.new("Complete todos los campos para cambiar contraseña")
      end
      if oldpass != user.password
        raise ArgumentError.new("Las contraseña anterior erronea")
      end
      if newpass != repass
        raise ArgumentError.new("Las contraseñas no coinciden")
      end
      newusername = user.username
      newemail = user.email
    end
    user.username = newusername
    user.password = newpass
    user.email = newemail
    unless user.valid?
      raise ValidationModelError.new("Datos para modificar el usuario incorrectos", user.errors)
    end
    user.update(username: newusername,
                password: newpass,
                email: newemail)
  end
end