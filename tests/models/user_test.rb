require File.expand_path '../../test_helper.rb', __FILE__

class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase		
  def test_name_existence
    # Arrange
    @user = User.new

    # Act
    @user.surname = nil

    # Assert
    assert_equal @user.valid?, false

	@user1 = User.new
	@user2 = User.new
    # Act
    @user1.username = "fede"
    @user2.username = "fede"

    # Assert
    assert_equal @user2.valid?, false

	@user3 = User.new
	@user4 = User.new
    # Act
    @user3.email = "fede"
    @user4.email = "fede"

    assert_equal @user4.valid?, false

	@user5 = User.new

    # Act
    @user5.password = nil

    # Assert
    assert_equal @user5.valid?, false

  end
end