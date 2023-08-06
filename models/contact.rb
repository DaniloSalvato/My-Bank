class Contact < Sequel::Model
    many_to_one :user
    
    plugin :validation_helpers

    def validate
        super
        validates_presence [:cellphone], allow_blank: true, message: 'cannot be blank'
        validates_format /\A\d{11}\z/, :telephone, allow_blank: true, message: 'invalid number'
        validates_format /\A\d{11}\z/, :cellphone, allow_blank: true, message: 'invalid number'
    end
    
    def self.get_contact_data

        print "\n"
        puts Rainbow("***Contatos***").bg(:cyan).bright
        contact_data = {}
        
        puts Rainbow("Telefone (Ex:19912341234) : ").white.bright
        contact_data[:telephone] = gets.chomp.to_i
        
        puts Rainbow("Celular (Ex:19912341234, não obrigatório*): ").white.bright
        contact_data[:cellphone] = gets.chomp.to_i
        
        contact_data
    end

    def self.create_contact(user)

        contact_data = get_contact_data
        contact = Contact.new(
            telephone: contact_data[:telephone].to_s,
            cellphone: contact_data[:cellphone].to_s
        )

        if contact.valid? 
            contact_data[:user_id] = user.id
            Contact.create(contact_data)
        else
            puts "Failed to save contact."
            contact.errors.each do |column, error|
                puts "#{column.capitalize}: #{error.join(', ')}"
            end
        end
    end

    def self.update_contact(user)
        loop do     
            puts "Contatos:"
            user.contacts.each_with_index do |contact, index|
                puts "#{index + 1}. Telefone: #{contact.telephone}, Celular: #{contact.cellphone}"
            end
        
            print "Digite o número do contato que deseja alterar (ou 0 para sair): "
            choice_contact = gets.chomp.to_i
        
            break if choice_contact == 0
        
            if choice_contact.between?(1, user.contacts.length)
                contact = user.contacts[choice_contact - 1]
                contact_data = get_contact_data
        
                contact.update(contact_data)
        
                puts 'Contato atualizado com sucesso!'
            else
                puts 'Invalid option. Try again.'
            end
        end
    end
end