# My Bank

Bem-vindo ao repositório do **My Bank**! 

## Visão Geral

O projeto **My Bank** é uma aplicação bancária simples desenvolvida em Ruby. Ele permite que os usuários gerenciem contas, realizem transações e visualizem o histórico de transações. O projeto tem como objetivo demonstrar o uso de princípios de programação orientada a objetos e interações básicas com banco de dados.

## Estrutura do Projeto

O projeto está organizado em diversos módulos:

- **Gerenciamento de Usuários**: Lida com o registro e autenticação de usuários.
- **Gerenciamento de Contas**: Gerencia contas de usuários, saldos e transações.
- **Histórico de Transações**: Registra registros de transações para cada conta.
- **Gerenciamento de Endereços**: Gerencia os endereços dos usuários associados às contas.

O projeto utiliza a gem Sequel para interações com o banco de dados.

## Como Começar

Para executar o projeto **My Bank** localmente, siga estas etapas:

1. Clone o repositório:
   
```sh
git clone https://github.com/DaniloSalvato/My_Bank.git
cd My_Bank
```

2. Instale as dependências usando o Bundler:
   
```sh
bundle install
```

3. Configure o banco de dados usando o Sequel, crie uma pasta "db" para que o codigo de migrations execute corretamente:

```sh
mkdir db
sequel -m migrations sqlite://db/bank.db
```

4. Execute a aplicação:

```sh
ruby app.rb
```
<br>

## Funcionalidades Principais
O projeto My Bank oferece diversas funcionalidades para gerenciamento de contas bancárias:

<br>

### Gerenciamento de Usuários
A aplicação permite o registro e autenticação de usuários, que podem criar e acessar suas contas.

<br>

### Gerenciamento de Contas
Os usuários podem criar, visualizar e gerenciar suas contas bancárias, incluindo operações como depósitos, saques e transferências.

<br>

### Histórico de Transações
Cada conta mantém um histórico detalhado de todas as transações realizadas.

<br>

### Gerenciamento de Endereços
Os usuários podem associar endereços às suas contas para manter os detalhes pessoais atualizados.

<br>

### Taxas de Juros e Cheque Especial
O projeto incorpora a funcionalidade de cheque especial, calculando taxas de juros diárias para saldos negativos.

<br>

### Problemas com Transactions durante a Criação de Usuário

Durante o desenvolvimento do projeto My Bank, tive problemas relacionado ao uso de Transactions ao criar um novo usuário. O objetivo era garantir que, se algo desse errado durante a criação do usuário, toda a operação fosse revertida de forma consistente, incluindo qualquer inserção de dados no banco de dados. ps: não foi resolvido.
