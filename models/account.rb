require 'securerandom'
require 'uuid'
require 'csv'
require 'json'

class Account < Sequel::Model
    many_to_one :user
    one_to_many :Historics

    ACCOUNT_TYPES = [ 'Crédito', 'Débito']
    OPTIONS = ['Criar conta', 'Acessar conta']
    ACTIONS = ['Saldo','Deposito', 'Saque', 'Transferência', 'Extrato de transações']
    TRANSACTIONS = ['TED', 'PIX']
    TAX_RATE = 0.01  
    FOLDER = 'extract_folder'
    HOME = Dir.pwd
    DAILY_TAX = 0.23 

    #Gerenciamento da conta
    def self.account_management
        loop do
            print "\n"
            puts Rainbow("===== CENTRAL DE CONTAS =====").bg(:cyan).bright
            print "\n"
            print Rainbow("Antes de continuar, confirme seu ID de usuário (ou 0 para sair): ").bright
            user_id = gets.chomp.to_i

            user = User[user_id]

            break if user_id == 0
            break puts Rainbow("User ID #{user_id} not found.").bg(:red).bright.underline if user.nil?
            break puts Rainbow('invalid or inconsistent user.').bg(:red).bright.underline if user.active == false
            
            print "\n"
            puts Rainbow("Opções:").bg(:magenta).bright
            print "\n"
            OPTIONS.each_with_index do |option, index|
                puts Rainbow("#{index + 1} - #{option}").bright.underline
            end

            print "\n"
            print Rainbow("Digite o número da opção desejada (ou 0 para sair): ").bright
            choice = gets.chomp.to_i

            break puts Rainbow("Saindo").bg(:green).bright.underline if choice == 0
        
            case choice
            when 1
                create_account(user)
            when 2
                account_access(user)
            else
                puts Rainbow('Invalid option.').bg(:red).bright.underline
            end
        end
    end

    #Ações da conta
    def self.account_access(user)
        
            account = account_selector(user)
            return if account.nil?

        loop do
            print "\n"
            puts Rainbow("Opções:").bg(:magenta).bright
            print "\n"

            ACTIONS.each_with_index do |action, index|
                puts Rainbow("#{index + 1}. #{action}").bright.underline
            end

            print "\n"
            print Rainbow("Escolha a ação desejada (ou 0 para sair): ").bright
            choice = gets.chomp.to_i 

            break Rainbow('Saindo.').bg(:green).bright if choice == 0

            case choice
            when 1
                check_balance(user, account.id)
            when 2
                deposit(user, account.id)
            when 3
                withdraw(user, account.id)
            when 4
                transfer(user, account.id)
            when 5
                extract_historic(user, account.id)
            else
                puts Rainbow('Invalid option. Try again.').bg(:red).bright.underline
            end
        end
    end

    #Selecionador de conta 
    def self.account_selector(user)
        selected_account = nil
        accounts_user = user.accounts

        return puts Rainbow('Not found accounts').bg(:red).bright.underline if accounts_user.empty?
    
        print "\n"
        puts Rainbow("===== SUAS CONTAS ===== ").bg(:magenta).bright

        print "\n"
        accounts_user.each_with_index do |account, index|
            puts Rainbow("#{index + 1} - Tipo: #{account.type}, Número: #{account.number}, Saldo: #{account.balance}").bright.underline if account.active == true
        end
    
        print "\n"
        print Rainbow("Digite o ID da conta que deseja realizar a operação: ").bright
        choice = gets.chomp.to_i
        print "\n"

        if choice.between?(1, accounts_user.length)
            selected_account = accounts_user[choice - 1]
            puts Rainbow("Você selecionou a conta #{selected_account.number}.").bg(:green).bright
        else
            puts Rainbow('Invalid option. Try again.').bg(:red).bright.underline
        end
        selected_account
    end

    #Criação da conta
    def self.create_account(user)

        print "\n"
        puts Rainbow("Opções:").bg(:magenta).bright
        print "\n"
        ACCOUNT_TYPES.each_with_index do |account_type, index|
            puts Rainbow("#{index + 1} - #{account_type}").bright.underline
        end

        print "\n"
        print Rainbow("Digite o número do tipo de conta desejado: ").bright
        choice = gets.chomp.to_i

        if choice.between?(1, ACCOUNT_TYPES.length)
            account_type = ACCOUNT_TYPES[choice - 1]

            account_data = { 
                user_id: user.id,
                number: generate_integer_uuid,
                type: account_type,
                balance: 0.0
                }

            new_account = Account.create(account_data)

            print "\n"
            puts Rainbow("#{user.name.capitalize} sua conta de #{account_type} criada com sucesso!.").bg(:green).bright.underline
            puts Rainbow("O número da sua nova conta é #{new_account.number}.").bg(:green).bright.underline
        else
            print "\n"
            puts Rainbow('Invalid option. Try again.').bg(:red).bright.underline
        end
    end

    #Saldo de uma conta
    def self.check_balance(user, account_id)
        account = Account[account_id]
      
        if account.user_id == user.id
            print "\n"
            puts Rainbow("Saldo atual da conta #{account.number} de #{user.name.capitalize}: R$#{account.balance}").bg(:green).bright
        else
            print "\n"
            puts Rainbow("The specified account does not belong to the user.").bg(:red).bright.underline
        end
    end 
      
    #metodo de depósito
    def self.deposit(user, account_id)
        account = Account[account_id]
      
        print "\n"
        print Rainbow('Informe o valor do depósito: ').bright
        amount = gets.chomp.to_f
      
        if amount <= 0 || !amount.is_a?(Float)
            print "\n"
            puts Rainbow('Invalid value. Deposit amount must be greater than zero.').bg(:red).bright.underline
        else
          account.balance += amount
          account.save
          Historic.save_transaction_history(transaction = 'Deposito', amount, account, destination_account = '-')
      
          puts Rainbow("Depósito de R$#{amount} realizado com sucesso na conta #{account.number}. ").bg(:green).bright
          puts Rainbow("Novo saldo R$#{account.balance}").bg(:green).bright
        end
      end

    #metodo de saque  
    def self.withdraw(user, account_id)
        account = Account[account_id]

        response = negative_balance(account)

        print "\n"
        puts Rainbow("Informe o valor do saque: ").bright
        amount = gets.chomp.to_f
        
        print "\n"
        return puts Rainbow('Invalid value. Cashout amount must be different from 0.').bg(:red).bright.underline if amount <= 0 || !amount.is_a?(Float)
        
        if account.balance - amount >= -100 && account.balance - amount < 0
            print Rainbow('Depois desse saque, você entrará no cheque especial deseja continuar? (Y/N)').bright
            response = gets.chomp

            if response.downcase == 'y'
                account.balance -= amount
                account.overdraft = Date.today
                account.save
                Historic.save_transaction_history(transaction = 'Saque', amount, account, destination_account = '-')
                puts Rainbow("Saque de R$#{amount} realizado com sucesso na conta #{account.number}.").bg(:green).bright
                puts Rainbow("Novo saldo R$#{account.balance}.").bg(:green).bright
            elsif response.downcase == "n"
                puts Rainbow('Transaction canceled.').bg(:green).bright
            else
                puts Rainbow('Invalid option.').bg(:red).bright.underline
            end

        elsif account.balance - amount >= 0
                account.balance -= amount
                account.save

                puts Rainbow("Saque de R$#{amount} realizado com sucesso na conta #{account.number}.").bg(:green).bright
                puts Rainbow("Novo saldo R$#{account.balance}").bg(:green).bright
                Historic.save_transaction_history(transaction = 'Saque', amount, account, destination_account = '-')
        else
            puts Rainbow("Insufficient amount to withdraw.").bg(:red).bright.underline
        end
    end

    #transferencia
    def self.transfer(user, account_id)

        origin_account = Account[account_id]

        response = negative_balance(origin_account)

        return puts Rainbow('Debit account cannot transfer!').bg(:green).bright if origin_account.type == 'Débito'

        loop do
            print "\n"
            puts Rainbow("Opções:").bg(:magenta).bright
            print "\n"

            TRANSACTIONS.each_with_index do |transaction, index|
                puts Rainbow("#{index + 1} - #{transaction}").bright.underline
            end

            print "\n"
            puts Rainbow("Escolha o tipo de transferência:").bright
            choice = gets.chomp.to_i
            transfer_choice = choice

            if choice.between?(1, TRANSACTIONS.length)
                transaction_select = TRANSACTIONS[choice - 1]
                print "\n"
                puts Rainbow("Você selecionou a transação #{transaction_select}.").bg(:green).bright
            else
                print "\n"
                puts Rainbow('Invalid option. Try again.').bg(:red).bright.underline
                break
            end
            
            print "\n"
            puts Rainbow("Informe o valor da transferência: ").bright
            amount = gets.chomp.to_f

            print "\n"
            break puts Rainbow('Invalid value.').bg(:red).bright.underline if amount <= -100 || !amount.is_a?(Float)
            break puts Rainbow('Insufficient balance on your account.').bg(:red).bright.underline if origin_account.balance < amount

            puts Rainbow("Informe o número da conta de destino: ").bright
            destination_account_number = gets.chomp
            destination_account = Account.find(number: destination_account_number)
            break puts Rainbow('Destination account not found.').bg(:red).bright.underline if destination_account.nil?

            if transfer_choice == 1
                if origin_account.user_id != destination_account.user_id
                    transfer_with_tax(origin_account, destination_account, amount)
                    break
                else
                    transfer_without_tax(origin_account, destination_account, amount)
                    break
                end
            elsif transfer_choice == 2
                transfer_without_tax(origin_account, destination_account, amount)
                break
            else
                print "\n"
                puts Rainbow('Invalid option.').bg(:red).bright.underline
            end
        end
    end

    def self.extract_historic(user, account_id)
        account = Account[account_id]
        
        historic_entries = Historic.where(account_id: account.id).order(:created_at)
        
        if historic_entries.empty?
            print "\n"
            puts Rainbow('There is no transaction history for this account.').bg(:green).bright 
        else
            print "\n"
            puts Rainbow("===== HISTORICO DE TRANSAÇÕES - #{account.number} =====").bg(:magenta).bright
            print "\n"

            historic_entries.each do |entry|
                if entry.destination_account == '-'
                    puts Rainbow("Transação: #{entry.transaction}, Saldo: R$#{entry.balance}, Data: #{entry.created_at.strftime('%d/%m/%Y %H:%M')}").bg(:green).bright if entry.transaction == 'Deposito'
                    puts Rainbow("Transação: #{entry.transaction}, Saldo: R$#{entry.balance}, Data: #{entry.created_at.strftime('%d/%m/%Y %H:%M')}").bg(:red).bright if entry.transaction == 'Saque'
                else
                    puts Rainbow("Transação: #{entry.transaction}, Saldo: R$#{entry.balance}, Conta de destino: #{entry.destination_account}, Data: #{entry.created_at.strftime('%d/%m/%Y %H:%M')}").bg(:cyan).bright
                end
            end

            print "\n"
            puts Rainbow('Gostaria de uma copia do extrato (Y/N): ').bright
            choice = gets.chomp

            if choice == 'Y' || choice == 'y'
                print "\n"
                file_name = generate_file_name
                export_to_json(historic_entries, account, file_name)
                export_to_csv(historic_entries, account, file_name)
            elsif choice == 'N' || choice == 'n'
                print "\n"
                puts Rainbow('Voltando...').bg(:green).bright
            else
                print "\n"
                puts Rainbow('Invalid options').bg(:red).bright.underline
            end
        end
    end

    private

    #transferências com taxa
    def self.transfer_with_tax(origin_account, destination_account, amount)
        total_amount = amount + (amount * TAX_RATE)
      
        origin_account.balance -= total_amount
        destination_account.balance += amount
        
        origin_account.overdraft = Date.today if origin_account.balance < 0

        origin_account.save
        destination_account.save

        Historic.save_transaction_history(transaction = 'TED', amount, origin_account, destination_account.number)

        print "\n"
        puts Rainbow("Transferência de R$#{amount} realizada com sucesso para a conta #{destination_account.number}.").bg(:green).bright
        puts Rainbow("Taxa de R$#{amount * TAX_RATE} aplicada.").bg(:green).bright
    end
      
      #transferências sem taxa
    def self.transfer_without_tax(origin_account, destination_account, amount)
      
        origin_account.balance -= amount
        destination_account.balance += amount
      
        origin_account.save
        destination_account.save
        Historic.save_transaction_history(transaction = 'PIX', amount, origin_account, destination_account.number)
      
        puts Rainbow("Transferência de R$#{amount} realizada com sucesso para a conta #{destination_account.number}.").bg(:green).bright
    end

    #gerador de numero de conta
    def self.generate_integer_uuid
        integer_uuid = SecureRandom.rand(100_000..999_999)
        new_number = integer_uuid.to_s
        new_number
    end

    def self.generate_file_name
        uuid_generator = UUID.new
        unique_id = uuid_generator.generate
        unique_id_string = unique_id.to_s
        file_name = "extract-#{unique_id_string}"
        file_name
    end

    def self.negative_balance(account)

        if account.balance < 0
            print "\n"
            puts Rainbow("A conta #{account.number} possui saldo negativo e esta no cheque especial.").bg(:red).bright
    
            since_date = account.overdraft # Data em que entrou em cheque especial
            formatted_since_date = Date.parse(since_date.strftime('%Y-%m-%d'))
    
            days_since = (Date.today - formatted_since_date)
            accumulated_interest = account.balance.abs * DAILY_TAX * days_since / 100.0
    
            print "\n"
            puts Rainbow("Saldo devedor: R$ #{account.balance.round(2)}").bg(:cyan).bright
            puts Rainbow("Taxa de juros acumulada: #{DAILY_TAX}%").bg(:cyan).bright
            puts Rainbow("Dias de juros acumulados: #{days_since}").bg(:cyan).bright
            puts Rainbow("Juros acumulados até hoje: R$ #{accumulated_interest.round(2).to_f}").bg(:cyan).bright
    
            print "\n"
            puts Rainbow("Deseja realizar um depósito para cobrir o saldo devedor? (Y/N)").bright
            choice = gets.chomp.downcase
    
            if choice == 'y' || choice == 'Y'
                print Rainbow("Digite o valor do depósito: ").bright
                deposit_amount = gets.chomp.to_f
        
                if deposit_amount >= accumulated_interest
                    new_balance = account.balance + deposit_amount - accumulated_interest
                    account.update(balance: new_balance, overdraft: nil)
                    print "\n"
                    puts Rainbow('Depósito realizado com sucesso.').bg(:green).bright
                    puts Rainbow("Novo saldo R$ #{new_balance.round(2)}").bg(:green).bright
                    Historic.save_transaction_history(transaction = 'Deposito', deposit_amount, account, destination_account = '-')
                else
                    print "\n"
                    puts Rainbow('O valor do depósito não é suficiente para cobrir os juros acumulados.').bg(:red).bright
                end
            else
                print "\n"
                puts Rainbow('No change').bg(:cyan).bright.underline
            end
        end
    end

    def self.export_to_csv(data, account, file_name)

        new_folder = Date.today.to_s 
        Dir.mkdir(FOLDER) unless Dir.exist?(FOLDER)
        Dir.chdir(FOLDER)
        Dir.mkdir('csv') unless Dir.exist?('csv')
        Dir.chdir('csv') 
        Dir.mkdir("#{account.id}_#{account.number}") unless Dir.exist?("#{account.id}_#{account.number}")
        Dir.chdir("#{account.id}_#{account.number}")
        Dir.mkdir(new_folder) unless Dir.exist?(new_folder)
        Dir.chdir(new_folder)

        CSV.open("#{file_name}.csv", 'wb') do |csv|
            csv << ['Transação', 'Saldo', 'Conta de Destino', 'Data']  
            data.each do |entry|
                if entry.destination_account == '-'
                    csv << [entry.transaction, entry.balance, '', entry.created_at.strftime('%d/%m/%Y %H:%M')]
                else
                    csv << [entry.transaction, entry.balance, entry.destination_account, entry.created_at.strftime('%d/%m/%Y %H:%M')]
                end
            end
        end

        puts Rainbow("Dados CSV exportados para #{file_name} com sucesso!").bg(:green).bright
        Dir.chdir(HOME)
    end

    def self.export_to_json(data, account, file_name)

        new_folder = Date.today.to_s 
        Dir.mkdir(FOLDER) unless Dir.exist?(FOLDER)
        Dir.chdir(FOLDER)
        Dir.mkdir('json') unless Dir.exist?('json')
        Dir.chdir('json')
        Dir.mkdir("#{account.id}_#{account.number}") unless Dir.exist?("#{account.id}_#{account.number}")
        Dir.chdir("#{account.id}_#{account.number}")
        Dir.mkdir(new_folder) unless Dir.exist?(new_folder)
        Dir.chdir(new_folder)

        json_data = JSON.pretty_generate(data.map(&:values))
    
        File.open("#{file_name}.json", 'wb') do |file|
            file.puts(json_data)
        end
    
        puts Rainbow("Dados JSON exportados para #{file_name} com sucesso!").bg(:green).bright
        Dir.chdir(HOME)
    end
end