Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:documents) do                                                                                   
      set_column_default :date, today()#CURRENT_TIMESTAMP                                                                                   
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end
end