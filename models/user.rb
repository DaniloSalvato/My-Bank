require_relative 'contact'
require_relative 'address'

class User < Sequel::Model
    one_to_many :contacts
    one_to_many :addresses
    one_to_many :accounts

    plugin :validation_helpers

    def validate
        super
        validates_presence :name, message: 'Name is required'
        validates_presence :email, message: 'Email is required'
        validates_presence :date_birth, message: 'Date of birth is required'
        validates_presence :document, message: 'Document is required'
        
        validates_format /\A[^@\s]+@[^@\s]+\z/, :email, allow_blank: true, message: 'Invalid email format'
        validates_unique :email, allow_blank: true, message: 'Must be unique'
        validates_unique :document, allow_blank: true, message: 'Must be unique'
        validates_format /\A(\d{11}|\d{14})\z/, :document, allow_blank: true, message: 'Must contain 11 or 14 numeric digits (CPF or CNPJ format)'
    end

    def self.create_user
        user_data = get_user_data
        new_user = User.new(
          name: user_data[:name],
          email: user_data[:email],
          date_birth: user_data[:date_birth],
          document: user_data[:document]
        )

        if new_user.valid?
            user = self.create(user_data)

            Contact.create_contact(user)
            Address.create_address(user)
                
            print "\n"
            puts Rainbow('Seu Usuário foi criado com sucesso!').bg(:green).bright.underline
            puts Rainbow("Será necessário informar seu ID #{user.id} para criação de contas.").bg(:green).bright.underline
            puts Rainbow('Por favor, guarde com segurança!').bg(:green).bright.underline
        else
            puts Rainbow('User data is invalid:').bg(:red).bright.underline
            new_user.errors.each do |error|
                puts  Rainbow(error.join(': ')).bg(:red).bright.underline
            end
        end
    end

    def self.update_user(user_id)
        user = User[user_id]
        return unless user

        user_data = get_user_data

        user.update(user_data)
        Contact.update_contact(user)
        Address.update_address(user)

        print "\n"
        puts Rainbow('Usuário atualizado com sucesso!').bg(:green).bright.underline
    end

    def self.delete_user(user_id)
        user = User[user_id]

        if user
          user.update(active: false)

          print "\n"
          puts Rainbow('Usuário desativado com sucesso!').bg(:green).bright.underline
        else
          print "\n"
          puts Rainbow('User not found. Check the entered ID.').bg(:red).bright.underline
        end
    end

    def self.get_user_data
        puts Rainbow("***Formulário de Cadastro***").bg(:cyan).bright
        user_data = {}
        
        print "\n"
        print Rainbow("Nome: ").white.bright
        user_data[:name] = gets.chomp.capitalize
        
        print Rainbow("E-mail: ").white.bright
        user_data[:email] = gets.chomp
        
        print Rainbow("Documento (CPF/CNPJ): ").white.bright
        user_data[:document] = gets.chomp
        
        print Rainbow("Data de Nascimento (AAAA-MM-DD): ").white.bright
        user_data[:date_birth] = gets.chomp
        
        user_data
    end
end
