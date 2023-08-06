Sequel.migration do
    change do
      create_table :accounts do
        primary_key :id
        foreign_key :user_id, :users 
        String :number, size: 10, null: false
        String :type, size: 255, null: false
        Float :balance, null:false
        Boolean :active, default: true
        DateTime :overdraft, default: nil, null: true 
        DateTime :created_at, default: Sequel::CURRENT_TIMESTAMP
      end
    end
  end