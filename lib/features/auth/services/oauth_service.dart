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
          },
          onPageFinished: (String url) {
            debugPrint('🔵 LinkedIn WebView page finished: $url');
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('🔴 LinkedIn WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(initialUrl));

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
            child: Column(
              children: [
                // Header with close button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Continue with LinkedIn',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          isCompleted = true;
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                ),
                // WebView
                Expanded(child: WebViewWidget(controller: controller)),
              ],
            ),
          ),
        );
      },
    );

    if (!isCompleted) {
      return null;
    }

    return authorizationCode;
  }
}

