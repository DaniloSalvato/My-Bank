require 'sequel'

Sequel.migration do
  change do
    create_table :contacts do
      primary_key :id
      foreign_key :user_id, :users 
      String :telephone, size: 100, null: false
      String :cellphone, size: 100, null: false
    end
  end
end