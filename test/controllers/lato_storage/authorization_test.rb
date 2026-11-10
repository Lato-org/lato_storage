require "test_helper"

module LatoStorage
  class AuthorizationTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = lato_users(:user_not_admin)
      authenticate_user
    end

    test "non admin is redirected from every section" do
      [lato_storage.root_url, lato_storage.blobs_url, lato_storage.attachments_url, lato_storage.variant_records_url].each do |url|
        get url
        assert_redirected_to lato.root_path, url
        assert_equal I18n.t("lato_storage.access_denied"), flash[:alert]
      end
    end

    test "non admin cannot run cleaner" do
      assert_no_difference -> { Lato::Operation.count } do
        post lato_storage.cleaner_url
      end
      assert_redirected_to lato.root_path
    end

    test "non admin gets 403 on json requests" do
      get lato_storage.blobs_url(format: :json)
      assert_response :forbidden
    end
  end

  class AdminAccessTest < ActionDispatch::IntegrationTest
    setup do
      Rails.cache.clear
      @user = lato_users(:user)
      authenticate_user
    end

    test "admin can open every section" do
      [lato_storage.blobs_url, lato_storage.attachments_url, lato_storage.variant_records_url].each do |url|
        get url
        assert_response :success, url
      end
    end

    test "blob links are expiring downloads opened safely" do
      ActiveStorage::Blob.create_and_upload!(io: StringIO.new("hello"), filename: "hello.txt", content_type: "text/plain")

      get lato_storage.blobs_url
      assert_select "a[target=_blank][rel~=noopener][href*='disposition=attachment']", text: /hello\.txt/
    end
  end
end
