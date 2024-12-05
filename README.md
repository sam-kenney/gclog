# gclog

[![Package Version](https://img.shields.io/hexpm/v/gclog)](https://hex.pm/packages/gclog)
[![Hex Docs](https://img.shields.io/badge/hex-docs-ffaff3)](https://hexdocs.pm/gclog/)

```sh
gleam add gclog
```

Writing string messages to Google Cloud Logging.

```gleam
import gclog
import gclog/entry
import gclog/severity
import gleam/json

pub fn main() {
    let logger = gclog.new_stderr(severity.Debug, json.string)

    logger
    |> gclog.info("Hello, world!")
}
```

Writing structured logs to Google Cloud Logging.

> Please note there is a limitation with structured logs where all fields will be nested as so: `{"jsonPayload":{"message":{<your fields here>}}`

```gleam
import gclog
import gclog/entry
import gclog/severity
import gleam/json.{type Json}

pub type Message {
    Message(id: String, client: String, content: String)
}

pub fn message_serializer(m: Message) -> Json {
    json.object([
        #("id", m.id),
        #("client", m.client),
        #("content", m.content),
    ])
}

pub fn main() {
    let logger = gclog.new_stderr(severity.Debug, message_serializer)

    logger
    |> gclog.info(Message(id: "12345", client: "Some Client", content: "Hello, world!"))
}
```

Writing complete Entries

```gleam
import gclog
import gclog/entry
import gclog/severity

// Note that you will need to provide the serializer in both the
// Logger constructor as well as manually serializing the value in
// `entry.new`.
let logger = gclog.new_stderr(severity.Debug, json.string)

logger
|> gclog.entry(
    entry.new(severity.Notice, json.string("Hello, world"))
    |> entry.with_source_location(line: 10, file: "app.gleam", function: "main")
    |> entry.with_trace(entry.Trace(project: "my-project", id: "12345"))
    |> entry.with_labels(dict.from_list([#("A", "b")]))
    |> entry.with_trace_sampled(True)
    |> entry.with_span_id("d39223e101960076"),
)
```

Further documentation can be found at <https://hexdocs.pm/gclog>.

## Development

```sh
gleam run   # Run the project
gleam test  # Run the tests
```
