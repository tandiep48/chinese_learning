/// Core API — shared `fromJson` validation helpers (plan rule 6).
///
/// Every model's `fromJson` uses these instead of casting JSON straight to a
/// field: a missing or wrong-typed value throws [ValidationException], which
/// the API layer surfaces as a clean error state. This is deliberately
/// stricter than the web, whose learner reads cast raw JSON to their TS
/// interfaces with no runtime check.
library;

import 'api_exception.dart';

/// Assert [value] is a JSON object and return it as a typed map.
Map<String, dynamic> asMap(dynamic value, {String what = 'value'}) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return value.cast<String, dynamic>();
  throw ValidationException(
    "Expected '$what' to be an object, got ${value.runtimeType}.",
  );
}

/// Assert [value] is a JSON array and return it.
List<dynamic> asList(dynamic value, {String what = 'value'}) {
  if (value is List) return value;
  throw ValidationException(
    "Expected '$what' to be a list, got ${value.runtimeType}.",
  );
}

String requireString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is String) return v;
  throw ValidationException(
    "Field '$key' must be a string, got ${v.runtimeType}.",
  );
}

int requireInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is int) return v;
  if (v is num) return v.toInt();
  throw ValidationException(
    "Field '$key' must be an int, got ${v.runtimeType}.",
  );
}

String? optString(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is String) return v;
  throw ValidationException(
    "Field '$key' must be a string or null, got ${v.runtimeType}.",
  );
}

int? optInt(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  throw ValidationException(
    "Field '$key' must be an int or null, got ${v.runtimeType}.",
  );
}

bool optBool(
  Map<String, dynamic> json,
  String key, {
  bool defaultValue = false,
}) {
  final v = json[key];
  if (v == null) return defaultValue;
  if (v is bool) return v;
  throw ValidationException(
    "Field '$key' must be a bool, got ${v.runtimeType}.",
  );
}

/// A field the backend serves as either a string or a number (e.g. a book's
/// `lesson` / `part`); normalized to a string.
String requireStringOrNum(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v is String) return v;
  if (v is num) return v.toString();
  throw ValidationException(
    "Field '$key' must be a string or number, got ${v.runtimeType}.",
  );
}

/// A list of strings (default `[]` when absent/null); each element is checked.
List<String> stringList(Map<String, dynamic> json, String key) {
  final v = json[key];
  if (v == null) return const [];
  final list = asList(v, what: key);
  return list.map((e) {
    if (e is String) return e;
    throw ValidationException(
      "Field '$key' must contain only strings, got ${e.runtimeType}.",
    );
  }).toList();
}

/// Parse a required list of objects into models via [fromJson]
/// (default `[]` when absent/null).
List<T> modelList<T>(
  Map<String, dynamic> json,
  String key,
  T Function(Map<String, dynamic>) fromJson,
) {
  final v = json[key];
  if (v == null) return const [];
  return asList(
    v,
    what: key,
  ).map((e) => fromJson(asMap(e, what: key))).toList();
}
