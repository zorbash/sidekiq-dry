# frozen_string_literal: true

module Sidekiq
  module Dry
    module Client
      class SerializationMiddleware
        def call(_worker_class, job, _queue, _redis_pool)
          job['args'].map! do |arg|
            next arg unless arg.is_a? ::Dry::Struct

            arg.to_h.merge(_type: arg.class)
          end

          yield
        end
      end
    end
  end
end
