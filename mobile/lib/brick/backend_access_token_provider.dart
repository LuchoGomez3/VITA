/// Provides the backend JWT used by Brick REST synchronization.
abstract class BackendAccessTokenProvider {
  /// Returns the current access token, or null when no session is available.
  Future<String?> getAccessToken();
}

/// Reads a development token from Dart defines.
class DartDefineBackendAccessTokenProvider implements BackendAccessTokenProvider {
  /// Creates a token provider backed by `--dart-define=VITA_BACKEND_ACCESS_TOKEN=...`.
  const DartDefineBackendAccessTokenProvider();

  static const _token = String.fromEnvironment('VITA_BACKEND_ACCESS_TOKEN');

  @override
  Future<String?> getAccessToken() async {
    if (_token.trim().isEmpty) {
      return null;
    }

    return _token;
  }
}
