class Address < Sequel::Model
    many_to_one :user

    plugin :validation_helpers

    def validate
        validates_presence [:street, :number, :city, :state, :uf, :zipcode], message: 'is required'
        validates_format /\A\d{5}-\d{3}\z/, :zipcode, message: 'must be in the format XXXXX-XXX'
    end

    def self.get_address_data

        print "\n"
        puts Rainbow("***Endereços***").bg(:cyan).bright
        address_data = {}
        
        print Rainbow("Rua: ").white.bright
        address_data[:street] = gets.chomp.capitalize
        
        print Rainbow("Número: ").white.bright
        address_data[:number] = gets.chomp
        
        print Rainbow("Complemento (não obrigatório*): ").white.bright
        address_data[:complement] = gets.chomp
        
        print Rainbow("Cidade: ").white.bright
        address_data[:city] = gets.chomp.capitalize
        
        print Rainbow("Estado: ").white.bright
        address_data[:state] = gets.chomp.capitalize
        
        print Rainbow("UF: ").white.bright
        address_data[:uf] = gets.chomp.uppercase
        
        print Rainbow("CEP (Ex:12345-123): ").white.bright
        address_data[:zipcode] = gets.chomp
        
        address_data
    end

    def self.create_address(user)
        
        address_data = get_address_data
            address = Address.new(
                street: address_data[:street],
                number: address_data[:number],
                complement: address_data[:complement],
                city: address_data[:city],
                state: address_data[:state],
                uf: address_data[:uf],
                zipcode: address_data[:zipcode]
             )

        if address.valid? 
            address_data[:user_id] = user.id
            Address.create(address_data)
        else
            puts "Failed to save address."
            contact.errors.each do |column, error|
                puts "#{column.capitalize}: #{error.join(', ')}"
            end
        end
    end

    def self.update_address(user)

        puts "Endereços:"
        user.addresses.each_with_index do |address, index|
            puts "#{index + 1}. #{address.street}, #{address.number}, #{address.city}, #{address.state}, #{address.uf}, #{address.zipcode}"
        end

        loop do
            print "Digite o número do contato que deseja alterar (ou 0 para sair): "
            choice_address = gets.chomp.to_i
            
            break if choice_address == 0

            if choice_address.between?(1, user.addresses.length)
                address = user.addresses[choice_address - 1]
                address_data = get_address_data
            
                address.update(address_data)
                puts "Endereço atualizado com sucesso!"
            else
                puts 'Invalid option. Try again.'
            end
        end
    end
end