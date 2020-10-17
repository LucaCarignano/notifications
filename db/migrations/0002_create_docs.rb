# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:documents) do
      primary_key :id
      String :title, null: false
      Date :date, null: false
      String :location, null: false, unique: true
      FalseClass :delete, default: false, null: false
    end
  end
  down do
    drop_table(:documents)
  end
end
