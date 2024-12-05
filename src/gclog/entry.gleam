//// Types and methods to construct an Entry.
import gclog/severity.{type Severity}
import gleam/dict.{type Dict}
import gleam/int
import gleam/json.{type Json}
import gleam/list
import gleam/option.{type Option, None, Some}

/// Represents a location in source code.
pub type SourceLocation {
  SourceLocation(
    file: Option(String),
    line: Option(Int),
    function: Option(String),
  )
}

fn source_location_serializer(s: SourceLocation) -> Json {
  json.object([
    #("file", json.nullable(s.file, of: json.string)),
    #(
      "line",
      json.nullable(
        option.map(s.line, fn(line) { int.to_string(line) }),
        of: json.string,
      ),
    ),
    #("function", json.nullable(s.function, of: json.string)),
  ])
}

fn labels_serializer(labels: Dict(String, String)) -> Json {
  let as_serializable = fn(kv) {
    let #(k, v) = kv
    #(k, json.string(v))
  }

  dict.to_list(labels)
  |> list.map(as_serializable)
  |> json.object
}

/// Validate traces.
/// Ensures the project id and trace id are provided.
pub type Trace {
  Trace(project: String, id: String)
}

fn trace_serializer(t: Trace) -> Json {
  json.string("projects/" <> t.project <> "/traces/" <> t.id)
}

/// A fairly complete Google Cloud Logging Entry.
pub type Entry {
  Entry(
    severity: Severity,
    message: json.Json,
    labels: Option(Dict(String, String)),
    trace: Option(Trace),
    span_id: Option(String),
    trace_sampled: Option(Bool),
    source_location: Option(SourceLocation),
  )
}

/// Create a new, minimal log Entry.
pub fn new(severity: Severity, message: Json) -> Entry {
  Entry(
    severity: severity,
    message: message,
    labels: None,
    trace: None,
    span_id: None,
    trace_sampled: None,
    source_location: None,
  )
}

/// Add labels to an existing Entry.
pub fn with_labels(entry: Entry, labels: Dict(String, String)) -> Entry {
  Entry(..entry, labels: Some(labels))
}

/// Add a trace to an existing Entry.
pub fn with_trace(entry: Entry, trace: Trace) -> Entry {
  Entry(..entry, trace: Some(trace))
}

/// Add a span id to an existing Entry.
pub fn with_span_id(entry: Entry, span_id: String) -> Entry {
  Entry(..entry, span_id: Some(span_id))
}

/// Specify the trace sampled field for an existing Entry.
pub fn with_trace_sampled(entry: Entry, trace_sampled: Bool) -> Entry {
  Entry(..entry, trace_sampled: Some(trace_sampled))
}

/// Add where the log was called from to an existing Entry.
pub fn with_source_location(
  entry: Entry,
  line lineno: Int,
  file fileloc: String,
  function func: String,
) -> Entry {
  Entry(
    ..entry,
    source_location: Some(SourceLocation(
      line: Some(lineno),
      file: Some(fileloc),
      function: Some(func),
    )),
  )
}

@internal
pub fn to_json(entry: Entry) -> json.Json {
  // FIXME(sam-kenney): Ugly but it works I guess?
  let message = [
    #("severity", json.string(severity.to_string(entry.severity))),
    #("message", entry.message),
  ]
  let message = case entry.labels {
    Some(labels) -> [
      #("logging.googleapis.com/labels", labels_serializer(labels)),
      ..message
    ]
    None -> message
  }
  let message = case entry.trace {
    Some(trace) -> [
      #("logging.googleapis.com/trace", trace_serializer(trace)),
      ..message
    ]
    None -> message
  }
  let message = case entry.span_id {
    Some(span_id) -> [
      #("logging.googleapis.com/spanId", json.string(span_id)),
      ..message
    ]
    None -> message
  }
  let message = case entry.trace_sampled {
    Some(ts) -> [
      #("logging.googleapis.com/trace_sampled", json.bool(ts)),
      ..message
    ]
    None -> message
  }
  let message = case entry.source_location {
    Some(sl) -> [
      #("logging.googleapis.com/sourceLocation", source_location_serializer(sl)),
      ..message
    ]
    None -> message
  }
  json.object(message)
}
