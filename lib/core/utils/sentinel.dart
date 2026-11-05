/// Sentinel used by `copyWith` methods to distinguish "argument omitted"
/// (keep the current value) from "argument explicitly passed as null"
/// (clear the field). A plain `?? this.field` fallback can't tell these
/// apart, which silently breaks any `copyWith(field: null)` call.
const Object unset = Object();
