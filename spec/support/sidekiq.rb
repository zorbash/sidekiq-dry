require 'sidekiq/testing'

Sidekiq.strict_args!

# Load all middlewares to be tested
Sidekiq.configure_client do |config|
  config.client_middleware do |chain|
    chain.prepend Sidekiq::Dry::Client::SerializationMiddleware
  end
end

# Class to test how the deserialization middleware interacts with
# other middlewares
class DummyMiddleware
  def call(_worker, job, _queue)
    yield
  rescue Exception => e
    report(job)
  end

  def report(job)

  end
end

Sidekiq::Testing.server_middleware do |chain|
  chain.add DummyMiddleware
  chain.add Sidekiq::Dry::Server::DeserializationMiddleware
end
