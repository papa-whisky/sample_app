require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: 'Example User', email: 'user@example.com', password: 'foobar',
      password_confirmation: 'foobar'
    )
  end

  test 'should be valid' do
    assert @user.valid?
  end

  test 'name should be present' do
    @user.name = ' '
    assert_not @user.valid?
  end

  test 'email should be present' do
    @user.email = ' '
    assert_not @user.valid?
  end

  test 'name should not be too long' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test 'email should not be too long' do
    @user.email = 'a' * 244 + '@example.com'
    assert_not @user.valid?
  end

  test 'email validation should accept valid addresses' do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn)

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test 'email validation should reject invalid addresses' do
    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com)

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test 'email addresses should be unique' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test 'email addresses should be saved as lower-case' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test 'password must be present (non-blank)' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'password must be at least 6 characters' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test 'authenticated? should return false when remember_digest is nil' do
    assert_not @user.authenticated?(:remember, '')
  end

  test 'associatied microposts should be destroyed' do
    @user.save
    @user.microposts.create!(content: 'blah')
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  test 'should follow and unfollow a user' do
    user = users(:example)
    other_user = users(:user_6)
    assert_not user.following?(other_user)
    user.follow(other_user)
    assert user.following?(other_user)
    assert other_user.followers.include?(user)
    user.unfollow(other_user)
    assert_not user.following?(other_user)
  end

  test 'feed should have the right posts' do
    user = users(:example)
    followed = users(:user_1)
    unfollowed = users(:user_2)

    followed.microposts.each do |post|
      assert user.feed.include?(post)
    end

    user.microposts.each do |post|
      assert user.feed.include?(post)
    end

    unfollowed.microposts.each do |post|
      assert_not user.feed.include?(post)
    end
  end
end
