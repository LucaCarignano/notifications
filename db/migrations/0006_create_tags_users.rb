# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:tags_users) do
      foreign_key :user_id, :users
      foreign_key :tag_id, :tags
      primary_key %i[user_id tag_id]
      index %i[user_id tag_id]
    end
  end
  down do
    drop_table(:tags_users)
  end
end
