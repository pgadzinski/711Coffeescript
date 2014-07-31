require 'test_helper'

class JobLoggingsControllerTest < ActionController::TestCase
  setup do
    @job_logging = job_loggings(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_loggings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create job_logging" do
    assert_difference('JobLogging.count') do
      post :create, job_logging: @job_logging.attributes
    end

    assert_redirected_to job_logging_path(assigns(:job_logging))
  end

  test "should show job_logging" do
    get :show, id: @job_logging
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @job_logging
    assert_response :success
  end

  test "should update job_logging" do
    put :update, id: @job_logging, job_logging: @job_logging.attributes
    assert_redirected_to job_logging_path(assigns(:job_logging))
  end

  test "should destroy job_logging" do
    assert_difference('JobLogging.count', -1) do
      delete :destroy, id: @job_logging
    end

    assert_redirected_to job_loggings_path
  end
end
