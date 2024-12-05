//// Simple Google Cloud Platform compliant logging library.

import gclog/entry.{type Entry}
import gclog/severity.{type Severity}
import gleam/io
import gleam/json

/// Write a log.
pub type Writer(t) =
  fn(String) -> t

/// Convert a type into JSON.
pub type Serializer(t) =
  fn(t) -> json.Json

/// Type used to write logs.
/// Any log messages written using the Logger must be serializable
/// using the provided Serializer.
///
/// # Examples
/// ```gleam
/// let logger = gclog.new_stderr(severity.Debug, json.string)
///
/// logger
/// |> gclog.info("Hello, world!")
/// ```
pub type Logger(t, w) {
  Logger(severity: Severity, writer: Writer(w), serializer: Serializer(t))
}

/// Create a new logger that writes logs to stdout.
pub fn new_stdout(
  severity: Severity,
  serializer: Serializer(t),
) -> Logger(t, Nil) {
  Logger(severity: severity, writer: io.println, serializer: serializer)
}

/// Create a new logger that writes logs to stderr.
pub fn new_stderr(
  severity: Severity,
  serializer: Serializer(t),
) -> Logger(t, Nil) {
  Logger(severity: severity, writer: io.println_error, serializer: serializer)
}

/// Log a complete Entry.
pub fn entry(logger: Logger(t, w), entry: Entry) -> Nil {
  case severity.to_int(entry.severity) >= severity.to_int(logger.severity) {
    True -> {
      entry.to_json(entry)
      |> json.to_string
      |> logger.writer
      Nil
    }
    False -> Nil
  }
}

/// Log a message specifying the severity manually.
pub fn log(logger: Logger(t, w), message: t, severity: Severity) -> Nil {
  logger.serializer(message)
  |> entry.new(severity, _)
  |> entry(logger, _)
}

/// Log a message at the Default level.
pub fn default(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Default)
}

/// Log a message at the Debug level.
pub fn debug(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Debug)
}

/// Log a message at the Info level.
pub fn info(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Info)
}

/// Log a message at the Notice level.
pub fn notice(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Notice)
}

/// Log a message at the Warning level.
pub fn warning(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Warning)
}

/// Log a message at the Error level.
pub fn error(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Error)
}

/// Log a message at the Critical level.
pub fn critical(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Critical)
}

/// Log a message at the Alert level.
pub fn alert(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Alert)
}

/// Log a message at the Emergency level.
pub fn emergency(logger: Logger(t, w), message: t) -> Nil {
  log(logger, message, severity.Emergency)
}
