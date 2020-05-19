Sequel.migration do 
  up do
    add_column :documents, :location, String, null: false, unique:true
  end

  down do 
    drop_column :documents, :location
  end
end