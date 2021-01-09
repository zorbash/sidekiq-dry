# frozen_string_literal: true

module Sidekiq
  module Dry
    module Server
      class DeserializationMiddleware
        def call(_worker, job, _queue)
          job['args'].map! do |arg|
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
          arg['_type'].constantize.new(arg.except('_type').symbolize_keys)
        end

        def constantize(klass)
          ActiveSupport::Inflector.constantize(klass)
        end
      end
    end
  end
end
