/// Core API — typed errors surfaced by the API client and model validation.
///
/// Repositories/providers catch these and map them to clean UI states (an
/// error message, or a redirect to login on [UnauthenticatedException]) rather
/// than letting a raw exception crash the widget tree.
library;

/// Base type for every API-layer failure.
class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      'ApiException(${statusCode ?? '-'}): $message';
}

/// HTTP 401 — no valid session/token. On either response path (envelope or
/// raw) the client throws this so callers can route to the login screen.
class UnauthenticatedException extends ApiException {
  const UnauthenticatedException([super.message = 'Not authenticated.'])
      : super(statusCode: 401);
}

/// Transport failure (no response at all: timeout, DNS, host unreachable).
class NetworkException extends ApiException {
  const NetworkException([super.message = 'Network error.']);
}

/// Response data was missing a required field or had the wrong type. Thrown by
/// the shared validators / model `fromJson` (plan rule 6 — validate, never
/// blind-cast).
class ValidationException extends ApiException {
  const ValidationException(super.message);
}
