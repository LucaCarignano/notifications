Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:documents) do                                                                                   
      add_column :date, :date                                                                                   
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end
end