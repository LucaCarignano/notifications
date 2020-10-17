# frozen_string_literal: true

require File.expand_path '../test_helper.rb', __dir__

class UserTest < MiniTest::Unit::TestCase
  MiniTest::Unit::TestCase
  def test_values_existence
    # Arrange
    @user1 = User.new

    # Act
    @user1.name = 'fede'
    @user1.surname = 'guti'
    @user1.username = 'fede1'
    @user1.email = 'fede1@gmail.com'
    @user1.password = '123456789'

    # Assert
    all_ok = assert_equal @user1.valid?, true

    # Act
    @user1.name = nil

    # Assert
    name_check = assert_equal @user1.valid?, false

    # Act
    @user1.name = 'fede'
    @user1.email = nil

    # Assert
    email_check = assert_equal @user1.valid?, false

    # Act
    @user1.email = 'fede@gmail.com'
    @user1.surname = nil

    # Assert
    surname_check = assert_equal @user1.valid?, false

    # Act
    @user1.surname = 'fede'
    @user1.username = nil

    # Assert
    user_check = assert_equal @user1.valid?, false

    # Act
    @user1.password = nil
    @user1.username = 'fede'

    # Assert
    pass_check = assert_equal @user1.valid?, false

    # Assert
    assert_equal (all_ok || email_check || name_check || user_check || pass_check || surname_check), true
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

  # no puedo chequear que sean unicos
  def test_values_unique
    # Arrange
    @user3 = User.new
    @user4 = User.new

    # Act
    @user3.name = 'fede'
    @user3.surname = 'guti'
    @user3.username = 'fede3'
    @user3.email = 'fede3@gmail.com'
    @user3.password = '123456789'

    @user4.name = 'fede'
    @user4.surname = 'guti'
    @user4.username = 'luca'
    @user4.email = 'luca@gmail.com'
    @user4.password = '123456789'

    # Assert
    @user3.save
    @user4.save
    all_ok = assert_equal @user3.valid? && @user4.valid?, true

    # Act
    @user4.email = 'fede3@gmail.com'
    @user4.save

    # Assert
    email_check = assert_equal @user4.valid?, false

    # Act
    @user4.email = 'luca@gmail.com'
    @user4.username = 'fede3'
    @user4.save

    # Assert
    user_check = assert_equal @user4.valid?, false

    # Assert
    assert_equal (all_ok || email_check || user_check), true
  end
end
