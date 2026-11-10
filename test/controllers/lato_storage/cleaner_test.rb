require "test_helper"

module LatoStorage
  class CleanerTest < ActionDispatch::IntegrationTest
    setup do
      @original_cache = Rails.cache
      Rails.cache = ActiveSupport::Cache::MemoryStore.new
      @user = lato_users(:user)
      authenticate_user
    end

    teardown { Rails.cache = @original_cache }

    test "dashboard asks confirmation before cleaning" do
      get lato_storage.root_url
      assert_select "a[data-turbo-method=post][data-turbo-confirm]"
    end

    test "cleaner starts operation and blocks concurrent runs" do
      assert_difference -> { Lato::Operation.count }, 1 do
        post lato_storage.cleaner_url
      end
      assert_response :redirect

      assert_no_difference -> { Lato::Operation.count } do
        post lato_storage.cleaner_url
      end
      assert_redirected_to lato_storage.root_path
      assert_equal I18n.t("lato_storage.cleaner_already_running"), flash[:alert]
    end
  end
end
