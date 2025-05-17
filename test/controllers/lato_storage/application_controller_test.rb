require "test_helper"

module LatoStorage
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = lato_users(:user)
    end

    # index
    ##

    test "index should response with redirect without session" do
      get lato_storage.root_url
      assert_response :redirect
    end

    test "index should response with success with session" do
      authenticate_user

      get lato_storage.root_url
      assert_response :success
    end
  end
end