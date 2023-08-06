require 'sequel'

Sequel.migration do
  change do
    create_table :users do
      primary_key :id
      String :name, size: 100, null: false
      String :email, size: 100, null: false
      String :document, size: 100, null: false, unique: true
      Date :date_birth
      Boolean :active, default: true
      DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
    end
  end
end