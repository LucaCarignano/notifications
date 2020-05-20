Sequel.migration do 
  up do
      alter_table(:documents) do
        drop_column :labelled
        drop_column :tag_involved
      end
  end

  down do 
    drop_table (:documents)
  end
end