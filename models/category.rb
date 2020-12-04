# frozen_string_literal: true

# Category class
class Category < Sequel::Model(:documents_tags)
  many_to_one :documents
  many_to_one :tags
end
