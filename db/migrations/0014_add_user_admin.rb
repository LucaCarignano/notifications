Sequel.migration do                                                                                           
  up do                                                                                                       
    alter_table(:users) do                                                                                   
      add_column :admin, FalseClass, default: false, null: false                                                                                   
      end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_column :users, :admin                                                                                      
  end
end