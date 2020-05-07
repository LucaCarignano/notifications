Sequel.migration do 
  up do
    rename_table(:docs, :documents) 
  end
  down do
    drop_table(:documents)
  end    
end