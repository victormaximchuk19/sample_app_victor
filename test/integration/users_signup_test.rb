require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    # routes to signup page, not required, only for including proper flow
    get signup_path
    # tests for the presence for proper post url in the form before submission
    assert_select "form[action='/signup']"
    # compares the value of User.count before and after block execution (post users_path...)
    assert_no_difference "User.count" do
      post signup_path, params: { user: { name: "",
                                          email: "user@invalid",
                                          password: "foo",
                                          password_confirmation: "bar" } }
    end
    # checks that the failed submission above re-renders the new action
    assert_template "users/new"
    assert_select 'div#error_explanation', count: 1  # 1 div with this id
    assert_select "div.field_with_errors", count: 8  # 8 divs with this class, 2 for each user attribute
    assert_select "div.alert.alert-danger"  # ensures a div with these classes exist
    assert_select "li", "Name can't be blank"
    assert_select "li", "Email is invalid"
    assert_select "li", "Password confirmation doesn't match Password"
    assert_select "li", "Password is too short (minimum is 6 characters)"
  end

  test "valid signup information with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, params: { user: { name: "Example User",
                                        email: "user@example.com",
                                        password: "password",
                                        password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template "users/show"
    assert is_logged_in?
  end
end