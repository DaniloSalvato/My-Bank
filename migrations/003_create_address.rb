require 'sequel'

Sequel.migration do
  change do
    create_table :addresses do
      primary_key :id
      foreign_key :user_id, :users 
      String :street, size: 255, null: false
      String :number, size: 10, null: false
      String :complement, size: 255, null: false
      String :city, size: 255, null: false
      String :state, size: 255, null: false
      String :uf, size: 10, null: false
      String :zipcode, size: 50, null: false
    end
  end
end