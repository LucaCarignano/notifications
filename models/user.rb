class User < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:name, :surname, :email, :password, :username]
		validates_unique [:email, :username]
		validates_format /\A.*@.*\..*\z/, :email, message: 'invalid email'
		validates_min_length(6, :password, message: 'password must have more than 5 caracters')	
	end
	many_to_many :tags
	many_to_many :documents
end