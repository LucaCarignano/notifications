Sequel.migration do 
  up do
      alter_table(:documents) do
        drop_column :documents, :labelled
        drop_column :documents, :tag_involved
      end
  end

  down do 
    drop_table(:documents)
  end
end