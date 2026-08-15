# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ActiveRecordJsonStreamer::Streamer do
  def collect_stream(streamer)
    String.new.tap do |buffer|
      streamer.enumerator.each { |chunk| buffer << chunk }
    end
  end

  it 'streams records as a JSON array with custom field mapper' do
    t1 = TestRecord.create!(name: 'Item 1', created_at: 2.hours.ago)
    t2 = TestRecord.create!(name: 'Item 2', created_at: 1.hour.ago)

    streamer = described_class.new(TestRecord.all, batch_size: 1, limit: nil) do |rec|
      { id: rec.id, name: rec.name }
    end

    raw_json = collect_stream(streamer)
    parsed = JSON.parse(raw_json)

    expect(parsed).to eq([
                           { 'id' => t2.id, 'name' => 'Item 2' },
                           { 'id' => t1.id, 'name' => 'Item 1' }
                         ])
  end

  it 'respects record limits and batch sizes' do
    5.times { |i| TestRecord.create!(name: "Item #{i}", created_at: i.minutes.ago) }

    streamer = described_class.new(TestRecord.all, batch_size: 2, limit: 3) do |rec|
      { name: rec.name }
    end

    parsed = JSON.parse(collect_stream(streamer))
    expect(parsed.size).to eq(3)
  end

  it 'supports ascending order' do
    TestRecord.create!(name: 'Oldest', created_at: 2.hours.ago)
    TestRecord.create!(name: 'Newest', created_at: 1.hour.ago)

    streamer = described_class.new(TestRecord.all, batch_size: 1, order: :asc) do |rec|
      { name: rec.name }
    end

    parsed = JSON.parse(collect_stream(streamer))
    expect(parsed).to eq([
                           { 'name' => 'Oldest' },
                           { 'name' => 'Newest' }
                         ])
  end
end
