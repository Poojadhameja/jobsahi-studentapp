/// Network Error Helper Utility
/// Provides functions to detect and format network-related errors
class NetworkErrorHelper {
  /// Checks if an error is related to network/internet connection
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;

    final errorString = error.toString().toLowerCase();
    final errorMessage = error is Exception
        ? error.toString()
        : errorString;

    final networkErrorKeywords = [
      'no internet',
      'internet connection',
      'connection timeout',
      'network',
      'offline',
      'connectivity',
      'connection failed',
      'timeout',
      'connection error',
      'socketexception',
      'failed host lookup',
      'network is unreachable',
      'connection refused',
    ];

    final lowerMessage = errorMessage.toLowerCase();
    return networkErrorKeywords.any(
      (keyword) => lowerMessage.contains(keyword),
    );
  }

  /// Extracts a user-friendly network error message from an error
  static String getNetworkErrorMessage(dynamic error) {
    if (error == null) {
      return 'No internet connection. Please check your network.';
    }

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (errorString.contains('connection error') ||
        errorString.contains('connection failed')) {
      return 'Connection failed. Please check your internet connection.';
    } else if (errorString.contains('socketexception') ||
        errorString.contains('failed host lookup')) {
      return 'No internet connection. Please check your network.';
    } else if (errorString.contains('network is unreachable')) {
      return 'Network is unreachable. Please check your connection.';
    } else {
      return 'No internet connection. Please check your network.';
    }
  }

  /// Extracts error message from exception or returns default
  static String extractErrorMessage(dynamic error, {String? defaultMessage}) {
    if (error == null) {
      return defaultMessage ?? 'An error occurred. Please try again.';
    }

    if (error is Exception) {
      final errorString = error.toString();
      // Remove "Exception: " prefix if present
      if (errorString.startsWith('Exception: ')) {
        return errorString.substring(11);
      }
      return errorString;
    }

    return error.toString();
  }
}


