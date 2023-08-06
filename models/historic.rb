class Historic < Sequel::Model
    many_to_one :account

    def self.save_transaction_history(transaction, amount, account, destination_account)

        transaction_data = {
          account_id: account.id,
          transaction: transaction,
          balance: amount,
          destination_account: destination_account
        }
        
        Historic.create(transaction_data)
      end

end