Sequel.migration do 
  up do
    add_column :docs, :date, Integer, null: false
    add_column :docs, :tags, String, null: false
    add_column :docs, :labelled, String, null: false
  end

  down do 
    drop_column :docs, :date
    drop_column :docs, :tags
    drop_column :docs, :labelled
  end
end