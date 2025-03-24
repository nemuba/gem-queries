# Queries
Short description and motivation.

## Usage
How to use my plugin.

## Installation
Add this line to your application's Gemfile:

```ruby
gem "queries"
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install queries
```

## Usage
To use the Queries gem, you can create a query class that inherits from `ApplicationQuery`. Here's an example of how to create a simple query to list all users:

```ruby
# app/queries/application_query.rb
class ApplicationQuery < Queries::Base
  # This is a base class for all queries.
  # You can add common methods or scopes here.
end

# app/queries/list_all_users.rb
class ListAllUsers < ApplicationQuery
  MODEL = User
end

# app/queries/sql/list_all_users.sql
SELECT * FROM users;


# List all users
ListAllUsers.call => [#<User id:...>, ..]

```

## Contributing
Contribution directions go here.

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
