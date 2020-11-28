require './exceptions/ValidationModelError.rb'
require 'sinatra/base'
require 'date'
require 'tempfile'
require 'sinatra'
require './models/user.rb'
require 'sinatra-websocket'

class DocumentService

	def self.addDocument(filename, file, title, labelleds, tags)
		if filename.empty? or title.empty? 
      raise ArgumentError.new("Complete todos los campos")
    end
    File.open("./public/file/#{filename}", 'wb') do |f|
        f.write(file.read)
      end
    time = Time.now.to_i
    name = "#{time}#{title}".gsub(' ', '')

    src = "file/#{name}.pdf"

    doc = Document.new(title: title, 
                       date: Date.today, 
                       location: src,
                       delete: 'f')

    unless doc.valid?
      raise ValidationModelError.new("Datos para crear el documento incorrectos", doc.errors)
    end
    doc.save
    FileUtils.cp(file.path, "public/#{src}")

    users_involved = []
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
      next unless tags.include? nombre

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
      return users_involved
    end

  def self.filterDoc users_filter, tags_filter, date_filter, name_filter, bot_filter, del_doc
    @documents = Document.where(delete: 'f').all
    if users_filter != ''
      user = User.find(username: users_filter)
      if user
        aux = user.documents_dataset
        @documents &= aux.to_a
      end
    end
    if tags_filter != ''
      tagg = Tag.find(name: tags_filter)
      if tagg
        aux2 = tagg.documents_dataset
        @documents &= aux2.to_a
      end
    end
    if date_filter != ''
      aux3 = Document.where(date: date_filter).all
      @documents &= aux3
    end
    if name_filter != ''
      name_filter = '%' + name_filter + '%'
      aux4 = Document.where(Sequel.like(:title, name_filter)).all
      @documents &= aux4
    end
    unless bot_filter

      del_doc.update(delete: 't')

      @documents = Document.where(delete: 'f')
    end
    return @documents
	end
end