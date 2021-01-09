# frozen_string_literal: true

require 'sidekiq'
require 'dry/struct'
require 'active_support/all'

require_relative 'dry/client/serialization_middleware'
require_relative 'dry/server/deserialization_middleware'

module Sidekiq
  module Dry
  end
end
