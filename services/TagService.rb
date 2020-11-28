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
end