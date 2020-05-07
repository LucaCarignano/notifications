class Document < Sequel::Model
	many_to_many :users
	many_to_many :tags
end