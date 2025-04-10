[![codecov](https://codecov.io/gh/nemuba/gem-queries/graph/badge.svg?token=8UC9DFEKCJ)](https://codecov.io/gh/nemuba/gem-queries)

# Queries

Uma gem Ruby para facilitar a execução de consultas SQL em aplicações Rails, permitindo a separação de consultas complexas em arquivos SQL dedicados, mantendo seu código mais organizado e legível.

## Motivação

O Queries foi criado para resolver o problema de consultas SQL complexas em aplicações Rails. Em vez de escrever SQL diretamente em seus modelos ou controladores, ou criar grandes scopes, você pode isolar suas consultas em arquivos SQL dedicados e organizados, tornando seu código mais limpo e fácil de manter.

## Instalação

Adicione esta linha ao Gemfile da sua aplicação:

```ruby
gem "queries"
```

E então execute:

```bash
bundle
```

Ou instale manualmente:

```bash
gem install queries
```

## Estrutura recomendada

```
app/
└── queries/
    ├── application_query.rb
    ├── list_users_query.rb
    ├── find_post_query.rb
    └── sql/
        ├── list_users_query.sql
        └── find_post_query.sql
```

## Uso

Para usar o Queries gem, siga estes passos:

### 1. Crie uma classe base para suas consultas

```ruby
# app/queries/application_query.rb
class ApplicationQuery < Queries::Base
  # Esta é uma classe base para todas as suas consultas.
  # Você pode adicionar métodos ou escopos comuns aqui.
end
```

### 2. Crie um arquivo SQL com sua consulta

```sql
# app/queries/sql/list_users_query.sql
SELECT * FROM users WHERE id = :id
```

### 3. Crie uma classe de consulta específica

```ruby
# app/queries/list_users_query.rb
class ListUsersQuery < ApplicationQuery
  MODEL = User
end
```

### 4. Execute sua consulta

```ruby
# Para buscar um usuário específico
user = ListUsersQuery.call(id: 123)

# Ou instancie e execute
query = ListUsersQuery.new(id: 123)
user = query.call
```

### Parâmetros de consulta

O Queries suporta parâmetros nomeados em suas consultas SQL. Use `:nome_parametro` em seu SQL e passe os valores correspondentes como um hash:

```sql
# app/queries/sql/search_posts_query.sql
SELECT * FROM posts
WHERE created_at >= :start_date
AND created_at <= :end_date
AND status = :status
```

```ruby
# Passando múltiplos parâmetros
posts = SearchPostsQuery.call(
  start_date: 1.month.ago,
  end_date: Date.today,
  status: 'published'
)
```

### Trabalhando com modelos

Defina a constante `MODEL` na sua classe de consulta para aproveitar os métodos do ActiveRecord nos resultados:

```ruby
class PostsWithComments < ApplicationQuery
  MODEL = Post
end
```

Se você não definir um modelo, a consulta retornará resultados brutos do banco de dados.

## Testes

O Queries foi projetado para ser facilmente testável. Veja um exemplo de teste RSpec:

```ruby
require 'rails_helper'

RSpec.describe ListUsersQuery, type: :query do
  describe "#call" do
    it "retorna usuários com o status especificado" do
      active_user = User.create(status: 'active')
      inactive_user = User.create(status: 'inactive')

      result = described_class.call(status: 'active')

      expect(result).to include(active_user)
      expect(result).not_to include(inactive_user)
    end
  end
end
```

## Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b minha-nova-feature`)
3. Commit suas alterações (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin minha-nova-feature`)
5. Crie um novo Pull Request

## Licença

A gem está disponível como código aberto sob os termos da [Licença MIT](https://opensource.org/licenses/MIT).
