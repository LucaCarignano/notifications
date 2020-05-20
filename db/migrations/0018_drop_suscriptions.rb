Sequel.migration do 
  up do
      drop_table (:suscriptions)
  end

  down do 
    drop_table (:suscriptions)
  end
end