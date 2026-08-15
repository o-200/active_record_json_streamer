# frozen_string_literal: true

require_relative 'active_record_json_streamer/version'
require_relative 'active_record_json_streamer/streamer'
require_relative 'active_record_json_streamer/controller'
require_relative 'active_record_json_streamer/railtie' if defined?(Rails::Railtie)

module ActiveRecordJsonStreamer
end
