class Labelled < Sequel::Model(:documents_users)
	many_to_one :users
	many_to_one :documents
end