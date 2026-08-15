# frozen_string_literal: true

require "spec_helper"

RSpec.describe ActiveRecordJsonStreamer::Controller do
  class DummyController < ActionController::Base
    include ActiveRecordJsonStreamer::Controller

    def export
      stream_json_export(TestRecord.all, filename: "records.json", batch_size: 2, limit: 10) do |rec|
        { name: rec.name }
      end
    end
  end

  it "sets HTTP headers and response body for streaming export" do
    TestRecord.create!(name: "Test Entry", created_at: Time.now)

    controller = DummyController.new
    controller.response = ActionDispatch::Response.new
    controller.export

    headers = controller.response.headers
    expect(headers["Content-Type"]).to eq("application/json")
    expect(headers["Content-Disposition"]).to match(/attachment; filename="records\.json"/)
    expect(headers["Cache-Control"]).to eq("no-cache")

    body_content = String.new
    controller.response.body.each { |chunk| body_content << chunk }
    parsed = JSON.parse(body_content)

    expect(parsed).to eq([ { "name" => "Test Entry" } ])
  end
end
