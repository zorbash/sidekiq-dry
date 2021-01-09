class UsersJob
  include Sidekiq::Worker

  def perform(*params)
    puts params.inspect
  end
end
