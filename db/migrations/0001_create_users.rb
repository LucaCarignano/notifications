# frozen_string_literal: true

Sequel.migration do
  up do
    create_table(:users) do
      primary_key :id
      String :name, null: false
      String :surname, null: false
      String :email, null: false
      String :username, null: false
      String :password, null: false
      FalseClass :admin, default: false, null: false
    end
  end
  down do
    drop_table(:users)
  end
end
