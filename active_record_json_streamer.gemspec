# frozen_string_literal: true

require_relative "lib/active_record_json_streamer/version"

Gem::Specification.new do |spec|
  spec.name          = "active_record_json_streamer"
  spec.version       = ActiveRecordJsonStreamer::VERSION
  spec.authors       = [ "Alex Abramov" ]
  spec.summary       = "High-performance memory-efficient JSON array streaming for ActiveRecord with Keyset pagination"
  spec.description   = "Stream large ActiveRecord relations as JSON arrays over HTTP using chunked response bodies and Keyset pagination without OOM."
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 3.0.0"

  spec.files         = Dir["lib/**/*", "LICENSE.txt", "README.md"]
  spec.require_paths = [ "lib" ]

  spec.add_dependency "activerecord", ">= 7.0"
  spec.add_dependency "actionpack", ">= 7.0"

  spec.add_development_dependency "rspec", "~> 3.12"
  spec.add_development_dependency "sqlite3"
  spec.add_development_dependency "rake"
end
