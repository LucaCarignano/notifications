Sequel.migration do 
  up do
    add_column :users, :name, String, null: false
  end

  down do 
    drop_column :users, :name
  end
end