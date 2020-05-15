class Document < Sequel::Model
	plugin :validation_helpers
	def validate
		super
		validates_presence [:title, :date]	
	end
	many_to_many :users
	many_to_many :tags
end