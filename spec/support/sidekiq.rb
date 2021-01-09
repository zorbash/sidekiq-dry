require 'sidekiq/testing'

# Load all middlewares to be tested
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.add Sidekiq::Dry::Client::SerializationMiddleware
  end
end

Sidekiq::Testing.server_middleware do |chain|
  chain.add Sidekiq::Dry::Server::DeserializationMiddleware
end
