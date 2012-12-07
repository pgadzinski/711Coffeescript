require 'spec_helper'

describe "home page" do
  it "displays the user's username after successful login" do
    get "/"
    assert_select "form.sessions" do
      assert_select "input[name=?]", "email"
      assert_select "input[name=?]", "password"
      assert_select "input[type=?]", "submit"
    end

    post "/login", :email => "peter@maxscheduler.com", :password => "111111"
    page.should have_content('Peter11')
    #assert_select ".header .username", :text => "Peter"
  end
end
