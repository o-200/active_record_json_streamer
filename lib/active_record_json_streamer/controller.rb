# frozen_string_literal: true

module ActiveRecordJsonStreamer
  module Controller
    DEFAULT_LIMIT = 50_000

    def stream_json_export(relation, filename:, batch_size: 1000, limit: DEFAULT_LIMIT, cursor_column: :created_at,
                           primary_key: :id, order: :desc, &field_mapper)
      response.headers['Content-Type'] = 'application/json'
      response.headers['Content-Disposition'] = %(attachment; filename="#{filename}")
      response.headers['Cache-Control'] = 'no-cache'
      response.headers['Last-Modified'] = Time.now.httpdate

      streamer = Streamer.new(
        relation,
        batch_size: batch_size,
        limit: limit,
        cursor_column: cursor_column,
        primary_key: primary_key,
        order: order,
        &field_mapper
      )

      self.response_body = streamer.enumerator
    end
  end
end
