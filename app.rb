require 'sequel'
require 'rainbow'

Sequel.sqlite('db/bank.db')

require_relative 'models/user'
require_relative 'models/contact'
require_relative 'models/address'
require_relative 'models/account'
require_relative 'models/historic'

OPTIONS = ['Criar usuário', 'Atualizar usuário', 'Deletar Usuário', 'Gerenciar contas', 'Sair']

loop do
    print "\n"
    puts Rainbow("===== Bem vindo ao My Bank =====").bg(:magenta).bright
    print "\n"
    OPTIONS.each_with_index do |option, index|
        puts Rainbow("#{index + 1}. #{option}").bright.underline
    end

    print "\n"

    puts Rainbow('Como podemos te ajudar hoje?').bg(:magenta).bright
    option = gets.chomp.to_i

    case option
    when 1
        print "\n"
        puts Rainbow('===== CRIANDO USUÁRIO =====').bg(:magenta).bright
        print "\n"
        User.create_user
    when 2
        print "\n"
        puts Rainbow('===== ATUALIZANDO USUÁRIO =====').bg(:magenta).bright
        print "\n"
        puts Rainbow('Digite o id do usuário que deseja atualizar: ').magenta.bright
        user_id = gets.chomp.to_i
        User.update_user(user_id)
    when 3
        print "\n"
        puts Rainbow('===== DELETANDO USUÁRIO =====').bg(:magenta).bright
        print "\n"
        puts Rainbow('Digite o id do usuário que deseja deletar: ').magenta.bright
        user_id = gets.chomp.to_i
        User.delete_user(user_id)
    when 4
        print "\n"
        Account.account_management   
    when 5
        print "\n"
        puts Rainbow('Atendimento encerrado').bg(:green).bright.underline
        break
    else
        print "\n"
        puts Rainbow('Invalid option').bg(:red).underline.bright
    end
end

