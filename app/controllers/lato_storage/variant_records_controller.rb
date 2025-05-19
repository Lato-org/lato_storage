module LatoStorage
  class VariantRecordsController < ApplicationController
    def index
      columns = %i[id blob_id variation_digest]
      sortable_columns = %i[]
      searchable_columns = %i[id blob_id]

      @variant_records = lato_index_collection(
        ActiveStorage::VariantRecord.all,
        columns: columns,
        sortable_columns: sortable_columns,
        searchable_columns: searchable_columns,
        default_sort_by: 'blob_id|DESC',
        pagination: 10,
      )
    end
  end
end