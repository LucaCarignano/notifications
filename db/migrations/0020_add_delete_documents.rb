Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:documents) do                                                                                   
      add_column :delete, FalseClass, default: false, null: false                                                                                   
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_column :documents, :delete                                                                                      
  end
end