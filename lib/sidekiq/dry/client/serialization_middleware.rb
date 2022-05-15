# frozen_string_literal: true

module Sidekiq
  module Dry
    module Client
      # Middleware which converts `Dry::Struct` job arguments to hashes with a
      # `_type` key to help deserializing back to the initial struct
      class SerializationMiddleware
        def call(_worker_class, job, _queue, _redis_pool)
          job['args'].map! do |arg|
            # Don't mutate non-struct arguments
            next arg unless arg.is_a? ::Dry::Struct

            # Set a `_type` argument to be able to instantiate
            # the struct when the job is performed
            arg.to_h.merge(_type: arg.class.to_s).deep_stringify_keys
          end

          yield
        end
      end
    end
  end
end
