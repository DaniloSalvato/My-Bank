Sequel.migration do
    change do
      create_table :historics do
        primary_key :id
        foreign_key :account_id, :accounts 
        String :transaction, size: 50, null: false
        Float :balance, null: false
        String :destination_account, size: 50, null: false
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end