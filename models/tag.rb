# frozen_string_literal: true

class Tag < Sequel::Model
  plugin :validation_helpers
  def validate
    super
    validates_presence [:name]
    validates_unique [:name]
  end
  many_to_many :users
  many_to_many :documents
end
