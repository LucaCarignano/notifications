require './exceptions/ValidationModelError.rb'
require './models/user.rb'

class DocumentService
  #def all_field_register?
    #username.empty? or password.empty? or name.empty? or email.empty? or surname.empty?
  #end

	def self.addDocument(filename, file, title)
		if filename.empty? or file.empty? or title.empty? 
      raise ArgumentError.new("Complete todos los campos")
    end
    File.open("./public/file/#{@filename}", 'wb') do |f|
        f.write(file.read)
      end
    time = Time.now.to_i
    name = "#{@time}#{params[:title]}".gsub(' ', '')
    src = "file/#{name}.pdf"

    doc = Document.new(title: title, 
                       date: Date.today, 
                       location: @src)

    unless user.valid?
      raise ValidationModelError.new("Datos para crear el usuario incorrectos", user.errors)
    end
    doc.save
    cp(file.path, "public/#{doc.location}")

    users_involved = []
        labelleds = params['labelled'].split('@')
        labelleds.each do |labelled|
          user = User.find(username: labelled)
          next unless user

          users_involved << user.id
          user.add_document(doc)
          user.save
        end

        categories = Tag.all
        categories.each do |category|
          nombre = category.name

          next unless params[nombre]

          category.add_document(doc)
          category.save
          labelled = Labelled.select(:user_id).where(document_id: doc.id)
          subscription = Subscription.select(:user_id).where(tag_id: category.id)
          users = User.where(id: subscription.except(labelled)).all
          users.each do |user|
            users_involved << user.id
            user.add_document(doc)
            user.save
          end
        end

        users_notificated = []

        settings.sockets.each do |s|
          users_notificated << s if users_involved.include?(s[:user])
        end
        users_notificated.uniq
        @cant_users = settings.sockets.length
        users_notificated.each do |s|
          id = Labelled.select(:document_id).where(readed: 'f', user_id: s[:user])
          @noti = Document.where(delete: 'f', id: id).count
          s[:socket].send(@noti.to_s)
        end
        @categories = Tag.all
        view_noti
        @succes = 'Documento cargado correctamente'
        erb :add_doc, layout: :layout_main

      else
        [500, {}, 'Internal server Error']
      end
    end


	end



	#def self.modifyUser(params)
	#	#######
	#end
end