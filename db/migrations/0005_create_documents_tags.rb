Sequel.migration do                                                                                           
  up do                                                                                                       
    create_table(:documents_tags) do
	  foreign_key :document_id, :documents
	  foreign_key :tag_id, :tags
	  primary_key [:document_id, :tag_id]
	  index [:document_id, :tag_id]
    end                                                                                                       
  end                                                                                                         
  down do                                                                                                     
    drop_table(:documents_tags)                                                                                        
  end
end
