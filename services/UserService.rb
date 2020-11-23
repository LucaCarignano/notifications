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
      @noti = Document.where(delete: 'f', id: id).count
    end
  end

	def self.modifyUser(user, editusername, editemail, editpass, 
                      botusername, botemail, botpass, newusername, 
                      newemail, newpass, repass, oldpass)    
    if !botusername.empty?
      @edituse = 'entro'
    elsif !botemail.empty?
      @editmail = 'entro'
    elsif !botpass.empty?
      @editpas = 'entro'
    end

    if @edituse != '' && editusername
      if newusername == ''
        @error = 'Ingrese un nombre de usuario'
      else
        user1 = User.find(username: params[:newuser])
        if user1
          @error = 'Nombre de usuario no disponible '
        else
          user.update(username: newusername)
          @succes = 'Nombre cambiado correctamente'
        end
      end
    elsif @editmail != '' && editemail
      if newemail == ''
        @error = 'Ingrese un email'
      else
        user1 = User.find(email: newemail)
        if user1
          @error = 'Email ya registrado'
        else
          user.update(email: newemail)
          @succes = 'Email cambiado correctamente'
        end
      end
    elsif @editpas != '' && editpass
      if newpass.empty? or repass.empty? or oldpass.empty?
        @error = 'Ingrese contraseña'
      elsif oldpass != user.password
        @error = 'contraseña incorrecta'
      elsif newpass != repass
        @error = 'contraseñas distintas'
      else
        user.update(password: newpass)
        @succes = 'Contraseña cambiada correctamente'
      end
    end
  end
end