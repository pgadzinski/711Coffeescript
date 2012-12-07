require 'test_helper'

class OperationhoursControllerTest < ActionController::TestCase
  setup do
    @operationhour = operationhours(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:operationhours)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create operationhour" do
    assert_difference('Operationhour.count') do
      post :create, operationhour: @operationhour.attributes
    end

    assert_redirected_to operationhour_path(assigns(:operationhour))
  end

  test "should show operationhour" do
    get :show, id: @operationhour
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @operationhour
    assert_response :success
  end

  test "should update operationhour" do
    put :update, id: @operationhour, operationhour: @operationhour.attributes
    assert_redirected_to operationhour_path(assigns(:operationhour))
  end

  test "should destroy operationhour" do
    assert_difference('Operationhour.count', -1) do
      delete :destroy, id: @operationhour
    end

    assert_redirected_to operationhours_path
  end
end
