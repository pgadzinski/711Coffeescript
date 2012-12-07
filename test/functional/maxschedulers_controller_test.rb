require 'test_helper'

class MaxschedulersControllerTest < ActionController::TestCase
  setup do
    @maxscheduler = maxschedulers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:maxschedulers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create maxscheduler" do
    assert_difference('Maxscheduler.count') do
      post :create, maxscheduler: @maxscheduler.attributes
    end

    assert_redirected_to maxscheduler_path(assigns(:maxscheduler))
  end

  test "should show maxscheduler" do
    get :show, id: @maxscheduler
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @maxscheduler
    assert_response :success
  end

  test "should update maxscheduler" do
    put :update, id: @maxscheduler, maxscheduler: @maxscheduler.attributes
    assert_redirected_to maxscheduler_path(assigns(:maxscheduler))
  end

  test "should destroy maxscheduler" do
    assert_difference('Maxscheduler.count', -1) do
      delete :destroy, id: @maxscheduler
    end

    assert_redirected_to maxschedulers_path
  end
end
