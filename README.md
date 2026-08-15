# ActiveRecordJsonStreamer

`ActiveRecordJsonStreamer` is a lightweight Ruby gem that enables high-performance, memory-efficient JSON array HTTP streaming for large `ActiveRecord` queries using **Keyset Pagination** and **Chunked Transfer Encoding**.

## Features

- **Constant $O(1)$ RAM usage**: Streams records directly from the database in batches without accumulating large objects in memory.
- **Keyset Pagination**: Fast cursor-based pagination over composite keys `(created_at, id)` instead of slow `OFFSET` queries.
- **Rails Integration**: Out-of-the-box support for `ActionController::Base` and `ActionController::API`.
- **Flexible Field Mapping**: Pass a block to customize the serialized JSON payload per record.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem "active_record_json_streamer"
```

And then execute:

```bash
$ bundle install
```

## Usage

### In Rails Controllers

```ruby
class Admin::ExportLogsController < ApplicationController
  include ActiveRecordJsonStreamer::Controller

  def export
    logs = UserActivityLog.where(created_at: 30.days.ago..)

    stream_json_export(logs, filename: "logs.json", batch_size: 1000) do |log|
      {
        id: log.id,
        action: log.action,
        user_id: log.user_id,
        created_at: log.created_at.iso8601
      }
    end
  end
end
```

### Options

| Parameter | Type | Default | Description |
|---|---|---|---|
| `relation` | `ActiveRecord::Relation` | *Required* | The query relation to stream. |
| `filename` | `String` | *Required* | Attachment filename for Content-Disposition header. |
| `batch_size` | `Integer` | `1000` | Number of records to load per database query batch. |
| `limit` | `Integer` / `nil` | `50_000` | Maximum total records to stream (`nil` for unlimited). |
| `cursor_column` | `Symbol` | `:created_at` | Primary sort/cursor column. |
| `primary_key` | `Symbol` | `:id` | Secondary sort/cursor column (unique identifier). |
| `order` | `Symbol` | `:desc` | Sort direction (`:desc` or `:asc`). |

## License

This gem is available as open source under the terms of the [MIT License](LICENSE.txt).
# active_record_json_streamer
