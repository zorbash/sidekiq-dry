# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Sidekiq::Dry::Server::DeserializationMiddleware do
  describe '#call' do
    let(:job) { instance_spy(UsersJob) }

    before do
      allow(UsersJob).to receive(:new).and_return(job)
    end

    context 'with a single struct parameter' do
      it 'deserializes the Hash arguments with _type into a struct' do
        params = UserParams.new(id: 42, email: 'admin@example.com')

        UsersJob.perform_async(params)
        UsersJob.drain

        expect(job).to have_received(:perform).with(params)
      end
    end

    context 'with multiple struct parameters' do
      it 'deserializes each struct parameter as a Hash', :aggregate_failures do
        param_1 = UserParams.new(id: 42, email: 'admin@example.com')
        param_2 = UserParams.new(id: 1337, email: 'support@example.com')

        UsersJob.perform_async(param_1, param_2)
        UsersJob.drain

        expect(job).to have_received(:perform).with(param_1, param_2)
      end
    end

    context 'with mixed struct and non-struct parameters' do
      it 'deserializes only the struct parameter as a Hash and leaves the rest untouched', :aggregate_failures do
        struct_param = UserParams.new(id: 42, email: 'admin@example.com')
        integer = 100
        string = 'some'
        hash = { one: 1, two: 2 }

        UsersJob.perform_async(integer, string, hash, struct_param)
        UsersJob.drain

        expect(job).to have_received(:perform).with(integer, string, hash.stringify_keys, struct_param)
      end
    end
  end
end
