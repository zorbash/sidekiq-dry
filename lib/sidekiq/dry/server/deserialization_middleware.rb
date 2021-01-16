# frozen_string_literal: true

module Sidekiq
  module Dry
    module Server
      # Middleware which instantiates `Dry::Struct` hash arguments
      class DeserializationMiddleware
        def call(_worker, job, _queue)
          job['args'].map! do |arg|
            # Only mutate Dry::Struct hashes
            next arg unless struct?(arg)

            to_struct(arg)
          end

          yield
        end

        private

        def struct?(arg)
          arg.is_a?(Hash) && arg.key?('_type')
        end

        def to_struct(arg)
          arg['_type'].constantize.new(arg.except('_type').deep_symbolize_keys)
        end
      end
    end
  end
end
