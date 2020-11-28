require './exceptions/ValidationModelError.rb'
require './models/user.rb'

class TagService

  def self.manageTag(user, suscribe, unsuscribe, tag)
     if suscribe
      categories = Tag.all
      categories.each do |category|
        nombre = category.name
        next unless params[nombre]
        category.add_user(user)
    elsif unsuscribe && tag
      user.remove_tag(Tag.find(name: tag))
    end
  end

  def self.makeTag(createtag, add, deltag, delete)
    if createtag != '' && add
      newtag = Tag.new(name: createtag)
      unless newtag.valid?
        raise ValidationModelError.new("Datos para crear el usuario incorrectos", tag.errors)
      end
      newtag.save
    elsif deltag != '' && delete
      tag = Tag.find(name: deltag)
      if tag
        users_tags = Subscription.where(tag_id: tag.id)
        users_tags.each(&delete)
        docs_tags = Category.where(tag_id: tag.id)
        docs_tags.each(&delete)
        tag.delete
      else
        raise ArgumentError.new("El tag es inexistente")
      end
    else
      raise ArgumentError.new("Inserte el nombre del tag a borrar")
    end
  end
end