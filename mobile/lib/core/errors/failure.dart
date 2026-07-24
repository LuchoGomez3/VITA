/// Simple failure value used by legacy result paths.
class Failure {
  /// Creates a failure with a user-facing message.
  const Failure(this.message);

  /// User-facing failure message.
  final String message;
}
