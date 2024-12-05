//// Contains the Severity type and helper methods.

/// The severity of the event described in a log entry.
pub type Severity {
  Default
  Debug
  Info
  Notice
  Warning
  Error
  Critical
  Alert
  Emergency
}

/// Convert a severity to a numerical representation.
pub fn to_int(severity: Severity) -> Int {
  case severity {
    Default -> 0
    Debug -> 100
    Info -> 200
    Notice -> 300
    Warning -> 400
    Error -> 500
    Critical -> 600
    Alert -> 700
    Emergency -> 800
  }
}

/// Convert a severity to a text representation.
pub fn to_string(severity: Severity) -> String {
  case severity {
    Default -> "DEFAULT"
    Debug -> "DEBUG"
    Info -> "INFO"
    Notice -> "NOTICE"
    Warning -> "WARNING"
    Error -> "ERROR"
    Critical -> "CRITICAL"
    Alert -> "ALERT"
    Emergency -> "EMERGENCY"
  }
}

