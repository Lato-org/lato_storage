module LatoStorage
  module ApplicationHelper
    def format_bytes(bytes)
      number_to_human_size(bytes.to_i)
    end

    def format_datetime(time)
      return '-' if time.nil?

      I18n.l(time, format: I18n.t('lato_storage.datetime_format'))
    end

    def active_storage_blob_byte_size(blob)
      format_bytes blob.byte_size
    end

    def active_storage_blob_created_at(blob)
      format_datetime blob.created_at
    end

    def active_storage_blob_filename(blob)
      active_storage_blob_link(blob)
    end

    def active_storage_attachment_created_at(attachment)
      format_datetime attachment.created_at
    end

    def active_storage_attachment_record_id(attachment)
      "#{attachment.record_type}##{attachment.record_id}"
    end

    def active_storage_attachment_blob_id(attachment)
      active_storage_blob_link(attachment.blob)
    end

    def active_storage_variant_record_blob_id(variant_record)
      active_storage_blob_link(variant_record.blob)
    end

    private

    # Expiring link, forced as download, so a file uploaded by someone else is never rendered inline on the admin origin.
    def active_storage_blob_link(blob)
      return ' - ' if blob.nil?

      url = main_app.rails_blob_path(blob, expires_in: LatoStorage.config.blob_url_expires_in, disposition: 'attachment')
      link_to url, target: '_blank', rel: 'noopener noreferrer', title: blob.filename.to_s, class: 'text-truncate d-block', style: 'max-width: 250px;' do
        safe_join([blob.filename.to_s, tag.span(I18n.t('lato_storage.new_tab'), class: 'visually-hidden')], ' ')
      end
    end
  end
end
