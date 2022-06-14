module Types
  include Dry.Types()
end

class UserParams < Dry::Struct
  attribute :id,          Types::Strict::Integer
  attribute :email,       Types::Strict::String
  attribute? :start_date, Types::Strict::Date
end

class UserWithAddressParams < Dry::Struct
  attribute :name, Types::String
  attribute :address do
    attribute :city,   Types::String
    attribute :street, Types::String
  end
end
