# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents_tags) do
      foreign_key :document_id, :documents
      foreign_key :tag_id, :tags
      primary_key %i[document_id tag_id]
      index %i[document_id tag_id]
    end
  end
  down do
    drop_table(:documents_tags)
  end
end
