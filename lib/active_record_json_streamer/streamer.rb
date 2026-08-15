# frozen_string_literal: true

require 'json'

module ActiveRecordJsonStreamer
  class Streamer
    DEFAULT_BATCH_SIZE = 1000
    DEFAULT_LIMIT = 50_000

    attr_reader :relation, :batch_size, :limit, :cursor_column, :primary_key, :order, :field_mapper

    def initialize(relation, batch_size: DEFAULT_BATCH_SIZE, limit: DEFAULT_LIMIT, cursor_column: :created_at,
                   primary_key: :id, order: :desc, &field_mapper)
      @relation = relation
      @batch_size = batch_size
      @limit = limit
      @cursor_column = cursor_column
      @primary_key = primary_key
      @order = order.to_sym
      @field_mapper = field_mapper
    end

    def enumerator
      Enumerator.new do |yielder|
        yielder << '['
        first = true
        emitted = 0
        col_ref, pk_ref = column_references
        current_relation = relation.order(cursor_column => order, primary_key => order)

        loop do
          remaining = limit - emitted if limit
          break if remaining && remaining <= 0

          fetch_size = remaining ? [batch_size, remaining].min : batch_size
          batch = current_relation.limit(fetch_size).to_a
          break if batch.empty?

          batch.each do |record|
            yielder << ',' unless first
            first = false
            emitted += emit_record(record, yielder)
          end

          break if batch.size < fetch_size

          current_relation = next_relation(batch.last, col_ref, pk_ref)
        end

        yielder << ']'
      end
    end

    private

    def column_references
      col = relation.connection.quote_column_name(cursor_column)
      pk = relation.connection.quote_column_name(primary_key)
      tbl = relation.connection.quote_table_name(relation.table_name)
      ["#{tbl}.#{col}", "#{tbl}.#{pk}"]
    end

    def emit_record(record, yielder)
      data = field_mapper ? field_mapper.call(record) : record.as_json
      yielder << JSON.generate(data)
      1
    end

    def next_relation(last_record, col_ref, pk_ref)
      last_cursor = last_record.public_send(cursor_column)
      last_pk = last_record.public_send(primary_key)
      operator = order == :desc ? '<' : '>'

      relation.where(
        "(#{col_ref} #{operator} :ca) OR (#{col_ref} = :ca AND #{pk_ref} #{operator} :pk)",
        ca: last_cursor, pk: last_pk
      ).order(cursor_column => order, primary_key => order)
    end
  end
end
