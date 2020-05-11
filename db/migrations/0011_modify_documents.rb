Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:documents) do                                                                                   
      set_column_type :date, :string                                                                                         
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_table(:documents)                                                                                        
  end
end
