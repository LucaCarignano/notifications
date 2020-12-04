# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

# Test for user class
class UserTest < MiniTest::Unit::TestCase
  def values_existence
    # Arrange
    @user1 = User.new

    # Act
    @user1.name = 'fede'
    @user1.surname = 'guti'
    @user1.username = 'fede1'
    @user1.email = 'fede1@gmail.com'
    @user1.password = '123456789'

    # Assert
    assert_equal @user1.valid?, true
  end

  def test_email_accurrancy
    # Arrange
    @user2 = User.new

    # Act
    @user2.name = 'fede'
    @user2.surname = 'guti'
    @user2.username = 'fede2'
    @user2.email = 'fede2@gmail.com'
    @user2.password = '123456789'

    # Assert
    all_ok = assert_equal @user2.valid?, true

    # Act
    @user2.email = 'fede'

    # Assert
    email_check = assert_equal @user2.valid?, false

    # Assert
    assert_equal (all_ok || email_check), true
  end

  def test_pass_accurrancy
    # Arrange
    @user = User.new

    # Act
    @user.name = 'fede'
    @user.surname = 'guti'
    @user.username = 'fede5'
    @user.email = 'fede5@gmail.com'
    @user.password = '123456789'

    # Assert
    all_ok = assert_equal @user.valid?, true

    # Act
    @user.password = 'fede'

    # Assert
    pass_check = assert_equal @user.valid?, false

    # Assert
    assert_equal (all_ok || pass_check), true
  end

  def test_unique_t
    # Arrange
    @user3 = User.new
    @user4 = User.new

    # Act
    @user3.name = 'fede'
    @user3.surname = 'guti'
    @user3.username = 'fede3'
    @user3.email = 'fede3@gmail.com'
    @user3.password = '123456789'

    @user4 = @user3
    @user4.username = 'luca'
    @user4.email = 'luca@gmail.com'

    # Assert
    assert_equal (@user3.valid? && @user4.valid?), true
  end

  def test_unique_f
    # Arrange
    @user5 = User.new
    @user6 = User.new

    # Act
    @user5.name = 'fede'
    @user5.surname = 'guti'
    @user5.username = 'fede3'
    @user5.email = 'fede3@gmail.com'
    @user5.password = '123456789'

    @user6 = @user5

    # Assert
    assert_equal (@user5.valid? && @user6.valid?), false
  end
end
