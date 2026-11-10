module LatoStorage
  class ApplicationController < Lato::ApplicationController
    layout 'lato/application'
    before_action :authenticate_session
    before_action :authenticate_lato_storage_admin
    before_action { active_sidebar(:lato_storage); active_navbar(:lato_storage) }

    CLEANER_LOCK_CACHE_KEY = 'LatoStorage::ApplicationController/cleaner_lock'

    def index
      @data = LatoStorage::PreloadDashboardDataJob.perform_now
    end

    def cleaner
      return cleaner_rejected(:cleaner_already_running, :conflict) unless acquire_cleaner_lock

      @operation = Lato::Operation.generate('Lato::ActiveStorageCleanerJob', {}, @session.user_id)

      respond_to do |format|
        if @operation.start
          format.html { redirect_to lato.operation_path(@operation) }
          format.json { render json: @operation }
        else
          Rails.cache.delete(CLEANER_LOCK_CACHE_KEY)
          format.html { redirect_to lato_storage.root_path, alert: I18n.t('lato_storage.cleaner_failed') }
          format.json { render json: @operation.errors, status: :unprocessable_entity }
        end
      end
    end

    protected

    def authenticate_lato_storage_admin
      return true if @session.user&.lato_storage_admin

      respond_to do |format|
        format.html { redirect_to lato.root_path, alert: I18n.t('lato_storage.access_denied') }
        format.json { head :forbidden }
      end
    end

    # The operation runs in background and its end is unknown here, so the lock simply expires
    def acquire_cleaner_lock
      Rails.cache.write(CLEANER_LOCK_CACHE_KEY, true, expires_in: 10.minutes, unless_exist: true)
    end

    def cleaner_rejected(message_key, status)
      respond_to do |format|
        format.html { redirect_to lato_storage.root_path, alert: I18n.t("lato_storage.#{message_key}") }
        format.json { render json: { error: I18n.t("lato_storage.#{message_key}") }, status: status }
      end
    end
  end
end