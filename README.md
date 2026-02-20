[![codecov](https://codecov.io/gh/nemuba/gem-queries/graph/badge.svg?token=8UC9DFEKCJ)](https://codecov.io/gh/nemuba/gem-queries)

# Queries

A Ruby gem to simplify the execution of SQL queries in Rails applications, allowing complex queries to be separated into dedicated SQL files, keeping your code more organized and readable.

## Motivation

Queries was created to solve the problem of complex SQL queries in Rails applications. Instead of writing SQL directly in your models or controllers, or creating large scopes, you can isolate your queries in dedicated, organized SQL files, making your code cleaner and easier to maintain.

## Installation

Add this line to your application's Gemfile:

```ruby
gem "queries"
```

And then execute:

```bash
bundle
```

Or install it manually:

```bash
gem install queries
```

## Recommended structure

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

## Usage

To use the Queries gem, follow these steps:

### 1. Create a base class for your queries

```ruby
# app/queries/application_query.rb
class ApplicationQuery < Queries::Base
  # This is a base class for all your queries.
  # You can add common methods or scopes here.
end
```

### 2. Create an SQL file with your query

```sql
# app/queries/sql/list_users_query.sql
SELECT * FROM users WHERE id = :id
```

### 3. Create a specific query class

```ruby
# app/queries/list_users_query.rb
class ListUsersQuery < ApplicationQuery
  MODEL = User
end
```

### 4. Execute your query

```ruby
# To fetch a specific user
user = ListUsersQuery.call(id: 123)

# Or instantiate and execute
query = ListUsersQuery.new(id: 123)
user = query.call
```

### Query parameters

Queries supports named parameters in your SQL queries. Use `:parameter_name` in your SQL and pass the corresponding values as a hash:

```sql
# app/queries/sql/search_posts_query.sql
SELECT * FROM posts
WHERE created_at >= :start_date
AND created_at <= :end_date
AND status = :status
```

```ruby
# Passing multiple parameters
posts = SearchPostsQuery.call(
  start_date: 1.month.ago,
  end_date: Date.today,
  status: 'published'
)
```

### Working with models

Define the `MODEL` constant in your query class to take advantage of ActiveRecord methods on the results:

```ruby
class PostsWithComments < ApplicationQuery
  MODEL = Post
end
```

If you don't define a model, the query will return raw database results.

## Testing

Queries is designed to be easily testable. Here is an example RSpec test:

```ruby
require 'rails_helper'

RSpec.describe ListUsersQuery, type: :query do
  describe "#call" do
    it "returns users with the specified status" do
      active_user = User.create(status: 'active')
      inactive_user = User.create(status: 'inactive')

      result = described_class.call(status: 'active')

      expect(result).to include(active_user)
      expect(result).not_to include(inactive_user)
    end
  end
end
```

## Contributing

1. Fork the project
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
