# frozen_string_literal: true

class Category < Sequel::Model(:documents_tags)
  many_to_one :documents
  many_to_one :tags
end
