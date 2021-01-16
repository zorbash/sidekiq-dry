# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Dry::Client::SerializationMiddleware do
  describe '#call' do
    before(:each) { Sidekiq::Worker.clear_all }

    context 'with a single struct parameter' do
      it 'serializes a struct parameter as a Hash', :aggregate_failures do
        params = UserParams.new(id: 42, email: 'admin@example.com')

        UsersJob.perform_async(params)

        expect(UsersJob.jobs.size).to be(1)

        job = UsersJob.jobs.first

        expect(job['args'].size).to be(1)
        expect(job['args'].first).to eql('id' => 42,
                                         'email' => 'admin@example.com',
                                         '_type' => 'UserParams')
      end
    end

    context 'with multiple struct parameters' do
      it 'serializes each struct parameter as a Hash', :aggregate_failures do
        param_1 = UserParams.new(id: 42, email: 'admin@example.com')
        param_2 = UserParams.new(id: 1337, email: 'support@example.com')

        UsersJob.perform_async(param_1, param_2)

        expect(UsersJob.jobs.size).to be(1)

        job = UsersJob.jobs.first

        expect(job['args'].size).to be(2)
        expect(job['args'].first).to eql('id' => 42,
                                         'email' => 'admin@example.com',
                                         '_type' => 'UserParams')
        expect(job['args'].last).to eql('id' => 1337,
                                         'email' => 'support@example.com',
                                         '_type' => 'UserParams')
      end
    end

    context 'with mixed struct and non-struct parameters' do
      it 'serializes only the struct parameter as a Hash and leaves the rest untouched', :aggregate_failures do
        struct_param = UserParams.new(id: 42, email: 'admin@example.com')
        integer = 100
        string = 'some'
        hash = { one: 1, two: 2 }

        Sidekiq::Testing.fake! do
          UsersJob.perform_async(integer, string, hash, struct_param)

          expect(UsersJob.jobs.size).to be(1)

          job = UsersJob.jobs.first

          expect(job['args'].size).to be(4)
          expect(job['args'].first).to eql(integer)
          expect(job['args'].at(1)).to eql(string)
          expect(job['args'].at(2)).to eql(hash.stringify_keys)
          expect(job['args'].at(3)).to eql('id' => 42,
                                           'email' => 'admin@example.com',
                                           '_type' => 'UserParams')
        end
      end
    end

    context 'with a nested struct' do
      let(:param) do
        UserWithAddressParams.new(name: 'Rick', address: { city: 'Seattle', street: 'Smith Road' })
      end

      it 'serializes the struct parameter as a Hash', :aggregate_failures do
        Sidekiq::Testing.fake! do
          UsersJob.perform_async(param)

          expect(UsersJob.jobs.size).to be(1)

          job = UsersJob.jobs.first
          args = job['args'].first

          expect(job['args'].size).to be(1)
          expect(args['name']).to eql(param.name)
          expect(args['address']['city']).to eql(param.address.city)
          expect(args['address']['street']).to eql(param.address.street)
        end
      end
    end
  end
end
