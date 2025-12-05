import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// No Internet Connection Widget
/// A reusable widget that displays when there's no internet connection
/// Shows the oops image, error message, and supports pull-to-refresh
class NoInternetWidget extends StatelessWidget {
  /// Callback function when refresh is triggered
  final VoidCallback? onRefresh;

  /// Custom error title (optional)
  final String? title;

  /// Custom error message (optional)
  final String? message;

  /// Whether to show the oops image (default: true)
  final bool showImage;

  /// Whether to enable pull-to-refresh (default: true)
  final bool enablePullToRefresh;

  const NoInternetWidget({
    super.key,
    this.onRefresh,
    this.title,
    this.message,
    this.showImage = true,
    this.enablePullToRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return enablePullToRefresh
        ? RefreshIndicator(
            onRefresh: () async {
              if (onRefresh != null) {
                onRefresh!();
              }
              // Add a small delay to show the refresh indicator
              await Future.delayed(const Duration(milliseconds: 500));
            },
            color: const Color(0xFFFF5C9A24),
            backgroundColor: Colors.white,
            child: _buildContent(),
          )
        : _buildContent();
  }

  /// Builds the main content of the no internet widget
  Widget _buildContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Main content section - centered
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Oops Image and Title together with Stack
              if (showImage) ...[
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Image.asset(
                        'assets/images/oops_image.png',
                        fit: BoxFit.contain,
                        height: 300,
                        errorBuilder: (context, error, stackTrace) {
                          // Fallback icon if image fails to load
                          return Container(
                            height: 300,
                            width: 300,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(
                                AppConstants.largeBorderRadius,
                              ),
                            ),
                            child: const Icon(
                              Icons.wifi_off,
                              size: 120,
                              color: Color(0xFFFF5C9A24),
                            ),
                          );
                        },
                      ),
                    ),
                    // Error Title positioned at bottom of image
                    Positioned(
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          title ?? 'No internet connection!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF5C9A24),
                            backgroundColor: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Error Title
                Text(
                  title ?? 'No internet connection!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF5C9A24),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppConstants.defaultPadding),

              // Error Message
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: Text(
                  message ??
                      'Something went wrong. Try refreshing the page or checking your internet connection. We\'ll see you in a moment!',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFFFF5C9A24),
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: AppConstants.largePadding),

              // Pull to refresh instruction
              if (enablePullToRefresh) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: AppConstants.smallPadding,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5C9A24).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                    border: Border.all(
                      color: const Color(0xFFFF5C9A24).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.refresh,
                        color: const Color(0xFFFF5C9A24),
                        size: 20,
                      ),
                      const SizedBox(width: AppConstants.smallPadding),
                      Text(
                        'Pull down to refresh',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFFFF5C9A24),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// No Internet Screen
/// A full-screen widget for no internet connection
/// Can be used as a standalone screen or within other screens
class NoInternetScreen extends StatelessWidget {
  /// Callback function when refresh is triggered
  final VoidCallback? onRefresh;

  /// Whether to show app bar (default: true)
  final bool showAppBar;

  /// App bar title (default: 'No Internet')
  final String? appBarTitle;

  /// Whether to enable pull-to-refresh (default: true)
  final bool enablePullToRefresh;

  const NoInternetScreen({
    super.key,
    this.onRefresh,
    this.showAppBar = true,
    this.appBarTitle,
    this.enablePullToRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: showAppBar
          ? AppBar(
              title: Text(
                appBarTitle ?? 'No Internet',
                style: const TextStyle(
                  color: AppConstants.textPrimaryColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppConstants.cardBackgroundColor,
              elevation: 0,
              iconTheme: const IconThemeData(
                color: AppConstants.textPrimaryColor,
              ),
              centerTitle: true,
            )
          : null,
      body: NoInternetWidget(
        onRefresh: onRefresh,
        enablePullToRefresh: enablePullToRefresh,
      ),
    );
  }
}

/// No Internet Error State Widget
/// A widget specifically designed to be used in BLoC error states
/// Automatically handles the refresh logic based on the provided callback
class NoInternetErrorWidget extends StatelessWidget {
  /// Callback function when refresh is triggered
  final VoidCallback? onRetry;

  /// Custom error message
  final String? errorMessage;

  /// Whether to show the oops image (default: true)
  final bool showImage;

  /// Whether to enable pull-to-refresh (default: true)
  final bool enablePullToRefresh;

  const NoInternetErrorWidget({
    super.key,
    this.onRetry,
    this.errorMessage,
    this.showImage = true,
    this.enablePullToRefresh = true,
  });

  @override
  Widget build(BuildContext context) {
    // Check if the error is related to internet connection
    final isInternetError = _isInternetError(errorMessage);

    if (isInternetError) {
      return NoInternetWidget(
        onRefresh: onRetry,
        enablePullToRefresh: enablePullToRefresh,
        showImage: showImage,
      );
    }

    // For other errors, show a generic error widget
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red.shade400),
          const SizedBox(height: AppConstants.largePadding),
          Text(
            'Something went wrong!',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.errorColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            child: Text(
              errorMessage ?? 'An unexpected error occurred. Please try again.',
              style: const TextStyle(
                fontSize: 16,
                color: AppConstants.errorColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppConstants.largePadding),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5C9A24),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                  vertical: AppConstants.defaultPadding,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.borderRadius,
                  ),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  /// Checks if the error message indicates an internet connection issue
  bool _isInternetError(String? message) {
    if (message == null) return false;

    final internetErrorKeywords = [
      'no internet',
      'internet connection',
      'connection timeout',
      'network',
      'offline',
      'connectivity',
      'connection failed',
      'timeout',
    ];

    final lowerMessage = message.toLowerCase();
    return internetErrorKeywords.any(
      (keyword) => lowerMessage.contains(keyword),
    );
  }
}
