Sequel.migration do                                                                                           
  up do                                                                                                       
      create_table(:docs) do                                                                                   
        primary_key :id                                                                                         
        String :title, null: false                                                                               
      end                                                                                                       
    end                                                                                                         
  down do                                                                                                     
      drop_table(:docs)                                                                                        
    end
  end
