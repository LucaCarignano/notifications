class User < Sequel::Model
	#plugin :
	def validate
		super
		error.add(:name, 'cannot be empty') if !name || name.empty?
		error.add(:username, 'cannot be empty') if !username || username.empty?
		error.add(:username, 'is already taken') if username && new? && User[{username: username}]
		error.add(:email, 'cannot be empty') if !email || email.empty?
		error.add(:email, 'is already taken') if email && new? && User[{email: email}]
		error.add(:password, 'cannot be empty') if !password || password.empty?
	end
end