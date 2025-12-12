import 'dart:io';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/app_constants.dart';
import '../../core/router/app_router.dart';
import '../../core/constants/app_routes.dart';
import 'api_service.dart';

/// FCM Service for handling Firebase Cloud Messaging
/// Manages token retrieval, saving, and notification handling
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final ApiService _apiService = ApiService();

  bool _isInitialized = false;
  String? _currentToken;

  /// Initialize FCM service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔵 FCM Service already initialized');
      return;
    }

    try {
      // Verify Firebase is initialized
      try {
        final app = Firebase.app();
        debugPrint('✅ Firebase app verified: ${app.name}');
      } catch (e) {
        debugPrint('🔴 Firebase not initialized: $e');
        throw Exception('Firebase must be initialized before FCM Service');
      }

      // Request notification permissions
      await _requestPermissions();

      // Initialize local notifications for foreground notifications
      await _initializeLocalNotifications();

      // Set up notification handlers
      _setupNotificationHandlers();

      // Get and save initial token if user is logged in
      await _getAndSaveToken();

      // Listen for token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        debugPrint('🔄 FCM Token refreshed: $newToken');
        _currentToken = newToken;
        _saveTokenToBackend(newToken);
      });

      _isInitialized = true;
      debugPrint('✅ FCM Service initialized successfully');
    } catch (e) {
      debugPrint('🔴 Error initializing FCM Service: $e');
    }
  }

  /// Request notification permissions
  /// Shows popup on first app launch if permission not granted
  Future<void> _requestPermissions() async {
    try {
      // Check if this is first launch (permission not requested before)
      final prefs = await SharedPreferences.getInstance();
      final permissionRequested = prefs.getBool('notification_permission_requested') ?? false;
      
      // Get current permission status
      final currentSettings = await _firebaseMessaging.getNotificationSettings();
      
      // Only request permission if:
      // 1. Not requested before (first launch), OR
      // 2. Permission is not determined (iOS) or not granted
      if (!permissionRequested || 
          currentSettings.authorizationStatus == AuthorizationStatus.notDetermined) {
        
        debugPrint('🔔 Requesting notification permission (first time or not determined)...');
        
        NotificationSettings settings =
            await _firebaseMessaging.requestPermission(
          alert: true,
          announcement: false,
          badge: true,
          carPlay: false,
          criticalAlert: false,
          provisional: false,
          sound: true,
        );

        debugPrint('🔔 Notification permission status: ${settings.authorizationStatus}');
        
        // Mark that permission has been requested
        await prefs.setBool('notification_permission_requested', true);
        
        // If permission granted, save token
        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          await _getAndSaveToken();
        }
      } else {
        debugPrint('🔔 Notification permission already requested. Current status: ${currentSettings.authorizationStatus}');
      }
    } catch (e) {
      debugPrint('🔴 Error requesting notification permissions: $e');
    }
  }

  /// Request notification permissions (public method)
  Future<NotificationSettings> requestPermissions() async {
    try {
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      debugPrint('🔔 Notification permission status: ${settings.authorizationStatus}');
      
      // Save token if permission granted and user is logged in
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        await _getAndSaveToken();
      }
      
      return settings;
    } catch (e) {
      debugPrint('🔴 Error requesting notification permissions: $e');
      rethrow;
    }
  }

  /// Get current notification permission status
  Future<NotificationSettings> getPermissionStatus() async {
    try {
      return await _firebaseMessaging.getNotificationSettings();
    } catch (e) {
      debugPrint('🔴 Error getting notification permission status: $e');
      rethrow;
    }
  }

  /// Initialize local notifications for foreground notifications
  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'jobsahi_notifications', // id
        'Jobsahi Notifications', // name
        description: 'Notifications for job updates and application status',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  /// Set up notification handlers
  void _setupNotificationHandlers() {
    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);

    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Handle notification tap when app is terminated
    _firebaseMessaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleNotificationTap(message);
      }
    });
  }

  /// Handle foreground notification
  Future<void> _handleForegroundNotification(RemoteMessage message) async {
    debugPrint('📬 Foreground notification received: ${message.messageId}');
    debugPrint('📬 Title: ${message.notification?.title}');
    debugPrint('📬 Body: ${message.notification?.body}');
    debugPrint('📬 Data: ${message.data}');

    // Show local notification
    await _showLocalNotification(message);
  }

  /// Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'jobsahi_notifications',
      'Jobsahi Notifications',
      channelDescription: 'Notifications for job updates and application status',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // ✅ Store notification data as JSON string for proper parsing
    final payloadJson = jsonEncode(message.data);
    await _localNotifications.show(
      message.hashCode,
      notification.title,
      notification.body,
      details,
      payload: payloadJson,
    );
  }

  /// Handle notification tap
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('👆 Notification tapped: ${message.messageId}');
    debugPrint('👆 Data: ${message.data}');

    final data = message.data;
    final type = data['type'] as String?;
    final jobId = data['job_id'] as String?;

    if (type == null) return;

    switch (type) {
      case 'new_job':
        if (jobId != null) {
          AppRouter.push(AppRoutes.jobDetailsWithId(jobId));
        } else {
          AppRouter.push(AppRoutes.home);
        }
        break;

      case 'shortlisted':
        // Navigate to application tracker or specific application
        if (jobId != null) {
          AppRouter.push(AppRoutes.studentApplicationDetailWithId(jobId));
        } else {
          AppRouter.push(AppRoutes.applicationTracker);
        }
        break;

      case 'selected':
        // Navigate to application success page or application tracker
        if (jobId != null) {
          AppRouter.push(AppRoutes.jobApplicationSuccessWithId(jobId));
        } else {
          AppRouter.push(AppRoutes.applicationTracker);
        }
        break;

      default:
        AppRouter.push(AppRoutes.home);
        break;
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('👆 Local notification tapped: ${response.payload}');
    
    if (response.payload == null || response.payload!.isEmpty) {
      // If no payload, just navigate to home
      AppRouter.push(AppRoutes.home);
      return;
    }

    try {
      // ✅ Parse payload - it's stored as JSON string
      final payloadJson = response.payload!;
      final Map<String, dynamic> data = jsonDecode(payloadJson);
      
      final type = data['type'] as String?;
      final jobId = data['job_id'] as String?;
      
      // Navigate based on notification type
      if (type != null) {
        switch (type) {
          case 'new_job':
            if (jobId != null) {
              AppRouter.push(AppRoutes.jobDetailsWithId(jobId));
            } else {
              AppRouter.push(AppRoutes.home);
            }
            break;
            
          case 'shortlisted':
            if (jobId != null) {
              AppRouter.push(AppRoutes.studentApplicationDetailWithId(jobId));
            } else {
              AppRouter.push(AppRoutes.applicationTracker);
            }
            break;
            
          case 'selected':
            if (jobId != null) {
              AppRouter.push(AppRoutes.jobApplicationSuccessWithId(jobId));
            } else {
              AppRouter.push(AppRoutes.applicationTracker);
            }
            break;
            
          default:
            AppRouter.push(AppRoutes.home);
            break;
        }
      } else {
        // If type not found, navigate to home
        AppRouter.push(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('🔴 Error parsing notification payload: $e');
      debugPrint('🔴 Payload: ${response.payload}');
      // Fallback: try to extract from string format if JSON parsing fails
      try {
        final payload = response.payload!;
        String? type;
        String? jobId;
        
        // Try to extract type and job_id using simple string matching
        if (payload.contains('type')) {
          final typeIndex = payload.indexOf('type');
          final afterType = payload.substring(typeIndex);
          final colonIndex = afterType.indexOf(':');
          if (colonIndex != -1) {
            final valuePart = afterType.substring(colonIndex + 1).trim();
            // Extract value (remove quotes if present)
            final cleanValue = valuePart
                .replaceAll('"', '')
                .replaceAll("'", '')
                .split(',')[0]
                .split('}')[0]
                .trim();
            type = cleanValue;
          }
        }
        
        if (payload.contains('job_id')) {
          final jobIdIndex = payload.indexOf('job_id');
          final afterJobId = payload.substring(jobIdIndex);
          final colonIndex = afterJobId.indexOf(':');
          if (colonIndex != -1) {
            final valuePart = afterJobId.substring(colonIndex + 1).trim();
            // Extract numeric value
            final cleanValue = valuePart
                .replaceAll('"', '')
                .replaceAll("'", '')
                .split(',')[0]
                .split('}')[0]
                .trim();
            jobId = cleanValue;
          }
        }
        
        if (type == 'selected' && jobId != null) {
          AppRouter.push(AppRoutes.jobApplicationSuccessWithId(jobId));
        } else if (type == 'shortlisted' && jobId != null) {
          AppRouter.push(AppRoutes.studentApplicationDetailWithId(jobId));
        } else if (type == 'new_job' && jobId != null) {
          AppRouter.push(AppRoutes.jobDetailsWithId(jobId));
        } else {
          AppRouter.push(AppRoutes.home);
        }
      } catch (e2) {
        debugPrint('🔴 Error in fallback parsing: $e2');
        AppRouter.push(AppRoutes.home);
      }
    }
  }

  /// Get FCM token
  Future<String?> getToken() async {
    try {
      // Wait a bit for Firebase to fully initialize
      await Future.delayed(const Duration(milliseconds: 500));
      
      final token = await _firebaseMessaging.getToken();
      _currentToken = token;
      debugPrint('🔑 FCM Token: $token');
      return token;
    } catch (e) {
      debugPrint('🔴 Error getting FCM token: $e');
      debugPrint('🔴 Error type: ${e.runtimeType}');
      debugPrint('🔴 Error details: ${e.toString()}');
      
      // Retry after delay if it's a network/IO error
      if (e.toString().contains('java.io') || 
          e.toString().contains('network') ||
          e.toString().contains('timeout')) {
        debugPrint('🔄 Retrying FCM token fetch after delay...');
        await Future.delayed(const Duration(seconds: 2));
        try {
          final retryToken = await _firebaseMessaging.getToken();
          _currentToken = retryToken;
          debugPrint('✅ FCM Token (retry): $retryToken');
          return retryToken;
        } catch (retryError) {
          debugPrint('🔴 Retry also failed: $retryError');
        }
      }
      
      return null;
    }
  }

  /// Get and save token if user is logged in
  Future<void> _getAndSaveToken() async {
    try {
      // Wait a bit more for Firebase to be ready
      await Future.delayed(const Duration(milliseconds: 1000));
      
      final isLoggedIn = await _apiService.isLoggedIn();
      if (isLoggedIn) {
        final token = await getToken();
        if (token != null && token.isNotEmpty) {
          await _saveTokenToBackend(token);
        } else {
          debugPrint('⚠️ FCM Token is null or empty, will retry later');
        }
      } else {
        debugPrint('🔵 User not logged in, skipping token save');
      }
    } catch (e) {
      debugPrint('🔴 Error getting and saving token: $e');
    }
  }

  /// Save FCM token to backend
  Future<bool> saveTokenToBackend() async {
    try {
      final token = await getToken();
      if (token != null) {
        return await _saveTokenToBackend(token);
      }
      return false;
    } catch (e) {
      debugPrint('🔴 Error saving token to backend: $e');
      return false;
    }
  }

  /// Internal method to save token to backend
  Future<bool> _saveTokenToBackend(String token) async {
    try {
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        debugPrint('🔴 User not logged in, skipping token save');
        return false;
      }

      final deviceType = Platform.isAndroid ? 'android' : 'ios';

      final response = await _apiService.post(
        AppConstants.saveFcmTokenEndpoint,
        data: {
          'fcm_token': token,
          'device_type': deviceType,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final success = responseData['success'] as bool? ?? false;
          if (success) {
            debugPrint('✅ FCM token saved successfully');
            return true;
          } else {
            debugPrint('🔴 Failed to save FCM token: ${responseData['message']}');
            return false;
          }
        }
      }

      debugPrint('🔴 Unexpected response format when saving FCM token');
      return false;
    } catch (e) {
      debugPrint('🔴 Error saving FCM token to backend: $e');
      return false;
    }
  }

  /// Get current token
  String? get currentToken => _currentToken;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
}

/// Background message handler
/// This must be a top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('📬 Background notification received: ${message.messageId}');
  debugPrint('📬 Title: ${message.notification?.title}');
  debugPrint('📬 Body: ${message.notification?.body}');
  debugPrint('📬 Data: ${message.data}');
}

