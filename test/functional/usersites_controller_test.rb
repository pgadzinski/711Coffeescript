require 'test_helper'

class UsersitesControllerTest < ActionController::TestCase
  setup do
    @usersite = usersites(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:usersites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create usersite" do
    assert_difference('Usersite.count') do
      post :create, usersite: @usersite.attributes
    end

    assert_redirected_to usersite_path(assigns(:usersite))
  end

  test "should show usersite" do
    get :show, id: @usersite
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @usersite
    assert_response :success
  end

  test "should update usersite" do
    put :update, id: @usersite, usersite: @usersite.attributes
    assert_redirected_to usersite_path(assigns(:usersite))
  end

  test "should destroy usersite" do
    assert_difference('Usersite.count', -1) do
      delete :destroy, id: @usersite
    end

    assert_redirected_to usersites_path
  end
end
