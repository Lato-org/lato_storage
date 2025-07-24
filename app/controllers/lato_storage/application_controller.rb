module LatoStorage
  class ApplicationController < Lato::ApplicationController
    layout 'lato/application'
    before_action :authenticate_session
    before_action :authenticate_lato_storage_admin
    before_action { active_sidebar(:lato_storage); active_navbar(:lato_storage) }

    def index
      # @blobs_count = ActiveStorage::Blob.count
      # @attachments_count = ActiveStorage::Attachment.count
      # @variant_records_count = defined?(ActiveStorage::VariantRecord) ? ActiveStorage::VariantRecord.count : 0
      # @deletable_blobs_count = ActiveStorage::Blob.unattached.where('active_storage_blobs.created_at < ?', 12.hours.ago).count
      
      # @total_storage = ActiveStorage::Blob.sum(:byte_size)
      # @avg_storage = @total_storage / @blobs_count if @blobs_count.positive?

      # @content_types = ActiveStorage::Blob.group(:content_type).count.sort_by { |_, count| -count }.first(5)

      # @largest_blobs = ActiveStorage::Blob.order(byte_size: :desc).limit(3)
      
      @data = LatoStorage::PreloadDashboardDataJob.perform_now
    end

    def cleaner
      @operation = Lato::Operation.generate('Lato::ActiveStorageCleanerJob', {}, @session.user_id)

      respond_to do |format|
        if @operation.start
          format.html { redirect_to lato.operation_path(@operation) }
          format.json { render json: @operation }
        else
          format.html { render :index, status: :unprocessable_entity }
          format.json { render json: @operation.errors, status: :unprocessable_entity }
        end
      end
    end

    protected

    def authenticate_lato_storage_admin
      return true if @session.user&.lato_storage_admin

      redirect_to lato.root_path, alert: 'You have not access to this section.'
    end
  end
end