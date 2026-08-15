# frozen_string_literal: true

module ActiveRecordJsonStreamer
  class Railtie < ::Rails::Railtie
    initializer "active_record_json_streamer.controller" do
      ActiveSupport.on_load(:action_controller_base) do
        include ActiveRecordJsonStreamer::Controller
      end
      ActiveSupport.on_load(:action_controller_api) do
        include ActiveRecordJsonStreamer::Controller
      end
    end
  end
end
