module LatoStorage
  class BlobsController < ApplicationController
    def index
      columns = %i[id filename byte_size created_at]
      sortable_columns = %i[byte_size created_at]
      searchable_columns = %i[id filename]

      @blobs = lato_index_collection(
        ActiveStorage::Blob.all,
        columns: columns,
        sortable_columns: sortable_columns,
        searchable_columns: searchable_columns,
        default_sort_by: 'created_at|DESC',
        pagination: 10,
      )
    end
  end
end