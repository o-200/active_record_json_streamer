# ActiveRecordJsonStreamer

`ActiveRecordJsonStreamer` is a lightweight, high-performance Ruby gem that enables memory-efficient HTTP JSON array streaming for large `ActiveRecord` queries using **Keyset Pagination** and **Chunked Transfer Encoding**.

---

## Value Proposition

Standard JSON exports in Rails applications often suffer from high memory consumption (OOM crashes) and database degradation due to slow SQL `OFFSET` pagination. `ActiveRecordJsonStreamer` solves these issues at the architectural level:

* **Constant Memory Footprint — $O(1)$ RAM**  
  Standard `render json: User.all` loads millions of records into server memory at once, building a huge JSON string in RAM and causing **Out Of Memory (OOM)** worker crashes (Puma/Unicorn). `ActiveRecordJsonStreamer` fetches records from the database in configurable batches and streams JSON array chunks directly into the HTTP response body. Server memory usage remains low and constant regardless of whether you stream 1,000 or 5,000,000 records.

* **Fast Database Queries Without `OFFSET` Latency (Keyset / Cursor Pagination)**  
  Unlike standard `find_each` or offset-based pagination, the gem uses a composite cursor over indexed columns `(created_at, id)`. Queries execute with predictable, lightning-fast performance whether fetching the 1st batch or the 1,000,000th record.

* **Minimal Time To First Byte (TTFB)**  
  The JSON array streaming starts immediately with `[`. Clients receive initial response chunks instantly without waiting for long-running database queries to fully complete.

* **Zero Infrastructure Overhead**  
  For medium to large data exports, there is no need for background job queues (Sidekiq/Resque), temporary disk storage, or cloud bucket uploads (S3). Data is streamed natively directly from your Rails controller endpoint.

---

## Use Cases

1. **Large Admin Panel Exports & Activity Logs**  
   Exporting authentication logs, transaction histories, or audit records over long date ranges directly from the admin UI without risking server timeouts or memory exhaustion.

2. **Service-to-Service Data Sync & ETL Pipelines**  
   Streaming large entity collections between microservices via HTTP REST APIs. The receiving client can consume and process the JSON stream concurrently (stream parsing) as chunks arrive.

3. **Direct Big-Data File Downloads in Web Browsers**  
   When a user clicks "Download Report (.json)", the browser immediately displays the save file dialog and streams incoming response bytes in real time.

4. **Replacing Heavy Background Job Export Pipelines**  
   Instead of complex background flows *(Enqueue Sidekiq Job ➔ Build File on Disk ➔ Upload to S3 ➔ Send Email with Download Link)*, you can serve exports of tens or hundreds of megabytes synchronously over a single HTTP stream.

---

## Key Features

- **Constant $O(1)$ RAM usage**: Streams records directly from the database in batches without accumulating large objects in memory.
- **Keyset Pagination**: Fast cursor-based pagination over composite keys `(created_at, id)` instead of slow `OFFSET` queries.
- **Rails Integration**: Out-of-the-box support for `ActionController::Base` and `ActionController::API`.
- **Flexible Field Mapping**: Pass a block to customize the serialized JSON payload per record.

---

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem "active_record_json_streamer"
```

And then execute:

```bash
$ bundle install
```

---

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

---

## Options

| Parameter | Type | Default | Description |
|---|---|---|---|
| `relation` | `ActiveRecord::Relation` | *Required* | The query relation to stream. |
| `filename` | `String` | *Required* | Attachment filename for Content-Disposition header. |
| `batch_size` | `Integer` | `1000` | Number of records to load per database query batch. |
| `limit` | `Integer` / `nil` | `50_000` | Maximum total records to stream (`nil` for unlimited). |
| `cursor_column` | `Symbol` | `:created_at` | Primary sort/cursor column. |
| `primary_key` | `Symbol` | `:id` | Secondary sort/cursor column (unique identifier). |
| `order` | `Symbol` | `:desc` | Sort direction (`:desc` or `:asc`). |

---

## License

This gem is available as open source under the terms of the [MIT License](LICENSE.txt).
