# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents_users) do
      foreign_key :document_id, :documents
      foreign_key :user_id, :users
      primary_key %i[document_id user_id]
      index %i[document_id user_id]
    end
  end
  down do
    drop_table(:documents_users)
  end
end
