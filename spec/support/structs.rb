module Types
  include Dry.Types()
end

class UserParams < Dry::Struct
  attribute :id,     Types::Strict::Integer
  attribute :email,  Types::Strict::String
end
