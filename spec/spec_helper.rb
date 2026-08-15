# frozen_string_literal: true

require 'active_record'
require 'action_pack'
require 'action_controller'
require 'sqlite3'
require 'rspec'

require_relative '../lib/active_record_json_streamer'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)

ActiveRecord::Schema.define do
  create_table :test_records, force: true do |t|
    t.string :name
    t.datetime :created_at
  end
end

class TestRecord < ActiveRecord::Base
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.after(:each) do
    TestRecord.delete_all
  end
end
