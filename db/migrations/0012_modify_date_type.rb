Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:documents) do                                                                                   
      drop_column :date                                                                                         
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end
end
