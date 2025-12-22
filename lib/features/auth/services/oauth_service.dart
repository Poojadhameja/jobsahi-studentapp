import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter/material.dart';

/// OAuth service for handling Google and LinkedIn authentication
class OAuthService {
  static final OAuthService _instance = OAuthService._internal();
  factory OAuthService() => _instance;
  OAuthService._internal();

  // Google Sign-In instance
  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  /// Sign in with Google
  /// Returns the access token if successful, null if cancelled or failed
  Future<String?> signInWithGoogle() async {
    try {
      debugPrint('🔵 Starting Google Sign-In flow');

      // Sign out first to ensure fresh sign-in
      await _googleSignIn.signOut();

      // Attempt to sign in
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        debugPrint('🔵 Google Sign-In cancelled by user');
        return null; // User cancelled the sign-in
      }

      debugPrint('🔵 Google Sign-In successful: ${googleUser.email}');

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Get access token (backend expects access_token, not id_token)
      final String? accessToken = googleAuth.accessToken;

      if (accessToken == null) {
        debugPrint('🔴 Google access token is null');
        return null;
      }

      debugPrint('🔵 Google access token obtained successfully');
      return accessToken;
    } catch (e) {
      debugPrint('🔴 Error during Google Sign-In: $e');
      return null;
    }
  }

  /// Sign in with LinkedIn using WebView
  /// Returns the authorization code if successful, null if cancelled or failed
  Future<String?> signInWithLinkedIn(BuildContext context) async {
    try {
      debugPrint('🔵 Starting LinkedIn OAuth flow');

      // Generate a random state for CSRF protection
      final state = DateTime.now().millisecondsSinceEpoch.toString();

      // LinkedIn OAuth URL
      final linkedInAuthUrl =
          'https://www.linkedin.com/oauth/v2/authorization?'
          'response_type=code'
          '&client_id=78se83t7nf8fid'
          '&redirect_uri=http://localhost/jobsahi-API/api/auth/oauth/linkedin/callback.php'
          '&state=$state'
          '&scope=openid%20profile%20email';

      debugPrint('🔵 LinkedIn OAuth URL: $linkedInAuthUrl');

      // Show WebView for LinkedIn authentication
      final authorizationCode = await _showLinkedInWebView(
        context,
        linkedInAuthUrl,
        state,
      );

      if (authorizationCode == null) {
        debugPrint('🔵 LinkedIn OAuth cancelled by user');
        return null;
      }

      debugPrint('🔵 LinkedIn authorization code obtained: $authorizationCode');
      return authorizationCode;
    } catch (e) {
      debugPrint('🔴 Error during LinkedIn OAuth: $e');
      return null;
    }
  }

  /// Show WebView for LinkedIn authentication
  Future<String?> _showLinkedInWebView(
    BuildContext context,
    String initialUrl,
    String expectedState,
  ) async {
    String? authorizationCode;
    bool isCompleted = false;
    final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(true);

    // Create WebViewController for webview_flutter 4.x
    final WebViewController controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('🔵 LinkedIn WebView navigation: $url');

            // Check if this is the callback URL
            if (url.contains('callback.php')) {
              // Extract authorization code from URL
              final uri = Uri.parse(url);
              final code = uri.queryParameters['code'];
              final state = uri.queryParameters['state'];
              final error = uri.queryParameters['error'];

              if (error != null) {
                debugPrint('🔴 LinkedIn OAuth error: $error');
                isCompleted = true;
                Navigator.of(context).pop();
                return NavigationDecision.prevent;
              }

              if (code != null && state == expectedState) {
                authorizationCode = code;
                isCompleted = true;
                Navigator.of(context).pop();
                return NavigationDecision.prevent;
              } else if (code != null) {
                // State mismatch, but still get the code
                debugPrint(
                  '⚠️ State mismatch: expected $expectedState, got $state',
                );
                authorizationCode = code;
                isCompleted = true;
                Navigator.of(context).pop();
                return NavigationDecision.prevent;
              }
            }

            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            debugPrint('🔵 LinkedIn WebView page started: $url');
            isLoadingNotifier.value = true;
          },
          onPageFinished: (String url) {
            debugPrint('🔵 LinkedIn WebView page finished: $url');
            isLoadingNotifier.value = false;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('🔴 LinkedIn WebView error: ${error.description}');
            isLoadingNotifier.value = false;
          },
        ),
      );

    // Show popup/dialog without header card
    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54, // Semi-transparent barrier instead of black
      builder: (BuildContext dialogContext) {
        // Load URL after dialog is shown to prevent black flash
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.loadRequest(Uri.parse(initialUrl));
        });
        
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16), // Rounded corners
          ),
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16), // Ensure corners are rounded
            child: Container(
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: const BoxDecoration(
                color: Colors.white, // White background to avoid black screen
              ),
              child: _LinkedInWebViewWidget(
                controller: controller,
                isLoadingNotifier: isLoadingNotifier,
                onClose: () {
                  isCompleted = true;
                  Navigator.of(dialogContext).pop();
                },
              ),
            ),
          ),
        );
      },
    ).then((_) {
      // Dialog was dismissed (by tapping outside or back button)
      if (!isCompleted) {
        isCompleted = true;
      }
    });

    if (!isCompleted) {
      return null;
    }

    return authorizationCode;
  }
}

/// Widget to show LinkedIn WebView with loading indicator
class _LinkedInWebViewWidget extends StatelessWidget {
  final WebViewController controller;
  final ValueNotifier<bool> isLoadingNotifier;
  final VoidCallback onClose;

  const _LinkedInWebViewWidget({
    required this.controller,
    required this.isLoadingNotifier,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isLoadingNotifier,
      builder: (context, isLoading, child) {
        return Container(
          color: Colors.white, // Ensure white background always
          child: Stack(
            fit: StackFit.expand,
            children: [
              // White background layer
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
              ),
              // WebView wrapped in white background
              Container(
                color: Colors.white,
                child: WebViewWidget(controller: controller),
              ),
              // Loading indicator overlay
              if (isLoading)
                Container(
                  color: Colors.white, // White background while loading
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

