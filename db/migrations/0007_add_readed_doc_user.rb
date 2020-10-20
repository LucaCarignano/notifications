# frozen_string_literal: true

Sequel.migration do
  up do
    alter_table(:documents_users) do
      add_column :readed, FalseClass, default: false, null: false
    end
  end
  down do
    drop_column :documents_users, :readed
  end
end
