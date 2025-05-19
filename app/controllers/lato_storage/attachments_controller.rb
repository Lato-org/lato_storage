module LatoStorage
  class AttachmentsController < ApplicationController
    def index
      columns = %i[id record_id blob_id created_at]
      sortable_columns = %i[created_at]
      searchable_columns = %i[id record_id record_type blob_id]

      @attachments = lato_index_collection(
        ActiveStorage::Attachment.all.includes(:blob),
        columns: columns,
        sortable_columns: sortable_columns,
        searchable_columns: searchable_columns,
        default_sort_by: 'created_at|DESC',
        pagination: 10,
      )
    end
  end
end