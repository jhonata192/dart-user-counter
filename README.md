# Contador de Usuários em Dart

Este repositório contém uma API simples escrita em Dart, que permite gerenciar a conexão de usuários com base em seus endereços IP. A aplicação utiliza a biblioteca **Shelf** para lidar com requisições HTTP e armazena os dados de conexão em um arquivo JSON.

## Funcionalidades

- **Conectar Usuário**: Ao enviar uma requisição `POST` para a rota `/conectar`, a API registra um novo usuário baseado no endereço IP, criando uma entrada com informações como ID de sessão e navegador.
- **Desconectar Usuário**: Ao enviar uma requisição `DELETE` para a rota `/desconectar`, a API remove o usuário da lista de conexões, atualizando a contagem de usuários.
- **Persistência de Dados**: Os dados de usuários conectados e a quantidade total de usuários são salvos em um arquivo JSON, permitindo a persistência entre reinicializações do servidor.
- **Middleware de IP**: Um middleware registra o IP do cliente para gerenciamento de sessões, garantindo que cada endereço IP seja tratado corretamente nas requisições.

## Estrutura do Projeto

- `contador.json`: Armazena informações sobre os usuários conectados.
- `main.dart`: Contém a lógica do servidor, incluindo gerenciamento de requisições e persistência de dados.

## Pré-requisitos

- Dart SDK instalado. Você pode baixá-lo em [dart.dev](https://dart.dev/get-dart).

## Como Executar

1. Clone este repositório:
   ```bash
   git clone https://github.com/jhonata192/dart-user-counter.git
   ```

2. Navegue até o diretório do projeto:
   ```bash
   cd dart-user-counter/lib
   ```

3. Execute o comando para iniciar o servidor:
   ```bash
   dart run contador2.dart
   ```

4. O servidor estará disponível na porta **6000**.

## Endpoints

- **Conectar Usuário**
  - **URL**: `/conectar`
  - **Método**: `POST`
  - **Descrição**: Registra um novo usuário baseado no IP do cliente.

- **Desconectar Usuário**
  - **URL**: `/desconectar`
  - **Método**: `DELETE`
  - **Descrição**: Remove o usuário baseado no IP do cliente.

## Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

## Contribuições

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## Contato

Se você tiver dúvidas ou sugestões, entre em contato com fjhonata14@gmail.com(mailto:fjhonata14@gmail.com).
