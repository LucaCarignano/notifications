Sequel.migration do 
  up do
  	alter_table(:documents) do                                                                                   
      rename_column :tags, :tag_involved
      end                                                                                                       
  end                                                                                                         

  down do 
    drop_column :documents, :tag_involved
  end
end