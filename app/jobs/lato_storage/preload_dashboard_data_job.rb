module LatoStorage
  class PreloadDashboardDataJob < ApplicationJob
    SEMAPHORE_CACHE_KEY = 'LatoStorage::PreloadDashboardDataJob/semaphore'
    DATA_CACHE_KEY = 'LatoStorage::PreloadDashboardDataJob/data'

    def perform(force_execution = false)
      return load_data unless LatoStorage.config.optimize_performances
      
      data = Rails.cache.read(DATA_CACHE_KEY)
      return data || {} if Rails.cache.read(SEMAPHORE_CACHE_KEY)

      if data && !force_execution
        LatoStorage::PreloadDashboardDataJob.perform_later(true)
        return data
      end

      Rails.cache.write(SEMAPHORE_CACHE_KEY, true, expires_in: 30.minutes)
      data = load_data
      Rails.cache.write(DATA_CACHE_KEY, data, expires_in: 12.hours)
      return data
    rescue StandardError => e
      Rails.logger.error "Error in LatoStorage::PreloadDashboardDataJob: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rails.cache.delete(SEMAPHORE_CACHE_KEY)
      nil
    end

    private

    def load_data
      blobs_count = ActiveStorage::Blob.count
      attachments_count = ActiveStorage::Attachment.count
      variant_records_count = defined?(ActiveStorage::VariantRecord) ? ActiveStorage::VariantRecord.count : 0
      # deletable_blobs_count = ActiveStorage::Blob.unattached.where('active_storage_blobs.created_at < ?', 12.hours.ago).count
      deletable_blobs_count = ActiveStorage::Blob.joins("LEFT JOIN active_storage_attachments ON active_storage_attachments.blob_id = active_storage_blobs.id")
                                                 .where("active_storage_attachments.blob_id IS NULL")
                                                 .where("active_storage_blobs.created_at < ?", 12.hours.ago).count
      total_storage = ActiveStorage::Blob.sum(:byte_size)
      avg_storage = blobs_count.positive? ? total_storage / blobs_count : 0
      content_types = ActiveStorage::Blob.group(:content_type).count.sort_by { |_, count| -count }.first(5)
      largest_blobs = ActiveStorage::Blob.order(byte_size: :desc).limit(3).map do |blob|
        {
          id: blob.id,
          filename: blob.filename.to_s,
          byte_size: blob.byte_size,
          created_at: blob.created_at,
          content_type: blob.content_type,
          service_name: blob.service_name,
          checksum: blob.checksum,
          url: Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true, expires_in: 12.hours)
        }
      end

      {
        blobs_count: blobs_count,
        attachments_count: attachments_count,
        variant_records_count: variant_records_count,
        deletable_blobs_count: deletable_blobs_count,
        total_storage: total_storage,
        avg_storage: avg_storage,
        content_types: content_types,
        largest_blobs: largest_blobs
      }
    end
  end
end
