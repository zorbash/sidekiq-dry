# Sidekiq::Dry

Gem to provide serialization and deserialization of [Dry::Struct][dry-struct]
arguments for [Sidekiq][sidekiq] jobs.

## Rationale

**Argument Validation**

By using `Dry::Struct` arguments you can choose to validate some attributes and mark
any of them as optional. An attempt to enqueue a job with invalid arguments will raise,
minimizing resource waste from jobs which would otherwise be retried multiple times without any chance of completing successfully.

Example:

```ruby
class Coupons::ApplyCouponJob::Params < Dry::Struct
  attribute :user_id,     Types::Strict::Integer
  attribute :coupon_code, Types::Strict::String
end

job_params = Coupons::ApplyCouponJob::Params.new(user_id: user.id, coupon_code: coupon.code)

Users::SendConfirmationEmailJob.perform_async(job_params)
```

**Documentation**

Instead of documenting the types of each job argument, which can easily become outdated, you can refer to the types of the attributes of the struct.

**Positional Arguments are Error Prone**

You won't ever have to remember the order of arguments of a job.

**Versioning**

Adding this gem does not break any existing jobs in your app.
It only works on jobs enqueued with `Dry::Struct` objects.

Adding a new attribute to a parameter struct won't break already enqueued jobs.

It's trivial to version your structs using either a `version` attribute:

```ruby
class Coupons::ApplyCouponJob::Params < Dry::Struct
  attribute :user_id,     Types::Strict::Integer
  attribute :coupon_code, Types::Strict::String
  attribute :version,     Types::Strict::String.default('1')
end
```

or versioned classes:

```ruby
class Coupons::ApplyCouponJob::Params::V1 < Dry::Struct
  attribute :user_id,     Types::Strict::Integer
  attribute :coupon_code, Types::Strict::String
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-dry'
```

And then execute:

    $ bundle install

Configure Sidekiq to use the middlewares provided by this gem:

```ruby
# File: config/initializers/sidekiq.rb
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Dry::Client::SerializationMiddleware
  end
end

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Dry::Server::DeserializationMiddleware
  end
end
```

See [Middleware usage](sidekiq-middlewares) on the Sidekiq wiki for more info.

## Usage

**Enqueuing Jobs**

```ruby
class Users::SendConfirmationEmailJob::Params < Dry::Struct
  attribute :email, Types::Strict::String
end

job_params = Users::SendConfirmationEmailJob::Params.new(email: user.email)

Users::SendConfirmationEmailJob.perform_async(job_params)
```

**Authoring Jobs**

```ruby
class Users::SendConfirmationEmailJob
  include Sidekiq::Worker

  def perform(params)
    # params is an instance of Users::SendConfirmationEmailJob::Params
    mail(to: params.email, subject: 'Welcome!')
  end
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/sidekiq-dry. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/sidekiq-dry/blob/master/CODE_OF_CONDUCT.md).


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Sidekiq::Dry project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/zorbash/sidekiq-dry/blob/master/CODE_OF_CONDUCT.md).

[dry-struct]: https://dry-rb.org/gems/dry-struct/1.0/
[sidekiq]: https://sidekiq.org/
[sidekiq-middlewares]: https://github.com/mperham/sidekiq/wiki/Middleware
