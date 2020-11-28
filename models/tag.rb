# frozen_string_literal: true

# Tag class
class Tag < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence :name, message: "Debe indicarnos el nombre del tag"
    validates_unique :name, message: "Tag existente"
  end
  many_to_many :users
  many_to_many :documents
end
