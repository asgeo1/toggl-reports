require 'test_helper'

class TimesheetControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

end
