import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/services/fcm_service.dart';

class NotificationPermissionPage extends StatefulWidget {
  const NotificationPermissionPage({super.key});

  @override
  State<NotificationPermissionPage> createState() =>
      _NotificationPermissionPageState();
}

class _NotificationPermissionPageState
    extends State<NotificationPermissionPage> {
  final FcmService _fcmService = FcmService();
  bool _isLoading = false;
  AuthorizationStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
  }

  Future<void> _checkPermissionStatus() async {
    try {
      final settings = await _fcmService.getPermissionStatus();
      setState(() {
        _permissionStatus = settings.authorizationStatus;
      });
    } catch (e) {
      debugPrint('🔴 Error checking permission status: $e');
    }
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final settings = await _fcmService.requestPermissions();
      setState(() {
        _permissionStatus = settings.authorizationStatus;
        _isLoading = false;
      });

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Notification permission granted!'),
              backgroundColor: AppConstants.successColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Notification permission denied'),
              backgroundColor: AppConstants.errorColor,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _openSettings() async {
    try {
      // Use permission_handler's openAppSettings which opens app-specific settings
      // This will open the app's permission settings page where user can enable notifications
      final opened = await openAppSettings();

      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to open settings. Please manually enable notifications in app settings.',
            ),
            backgroundColor: AppConstants.errorColor,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('🔴 Error opening settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppConstants.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getStatusText() {
    switch (_permissionStatus) {
      case AuthorizationStatus.authorized:
        return 'Enabled';
      case AuthorizationStatus.denied:
        return 'Denied';
      case AuthorizationStatus.notDetermined:
        return 'Not Determined';
      case AuthorizationStatus.provisional:
        return 'Provisional';
      default:
        return 'Unknown';
    }
  }

  Color _getStatusColor() {
    switch (_permissionStatus) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return AppConstants.successColor;
      case AuthorizationStatus.denied:
        return AppConstants.errorColor;
      default:
        return AppConstants.warningColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.settings);
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text('Notifications', style: AppConstants.headingStyle),
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: AppConstants.textPrimaryColor,
            ),
            onPressed: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go(AppRoutes.settings);
              }
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.largePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppConstants.defaultPadding),

                // Notification Icon
                Center(
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_outlined,
                      size: 60,
                      color: AppConstants.primaryColor,
                    ),
                  ),
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Title
                Text(
                  'Stay Updated',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.primaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.defaultPadding),

                // Description
                Text(
                  'Get notified about new job opportunities, application updates, and important messages.',
                  style: AppConstants.bodyStyle.copyWith(
                    color: const Color(0xFF666666),
                    height: 1.6,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Permission Status Card
                if (_permissionStatus != null)
                  Container(
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: _getStatusColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                      border: Border.all(
                        color: _getStatusColor().withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Permission Status',
                              style: AppConstants.captionStyle.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColor(),
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          _permissionStatus == AuthorizationStatus.authorized ||
                                  _permissionStatus ==
                                      AuthorizationStatus.provisional
                              ? Icons.check_circle
                              : Icons.cancel,
                          color: _getStatusColor(),
                          size: 32,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Benefits List
                _buildBenefitItem(
                  Icons.work_outline,
                  'Job Alerts',
                  'Get notified when new jobs match your profile',
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildBenefitItem(
                  Icons.update_outlined,
                  'Application Updates',
                  'Stay informed about your application status',
                ),
                const SizedBox(height: AppConstants.defaultPadding),
                _buildBenefitItem(
                  Icons.message_outlined,
                  'Messages',
                  'Receive important messages from employers',
                ),

                const SizedBox(height: AppConstants.largePadding * 2),

                // Action Button
                if (_permissionStatus == AuthorizationStatus.authorized ||
                    _permissionStatus == AuthorizationStatus.provisional)
                  ElevatedButton(
                    onPressed: () {
                      // Already granted, show info
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Notifications are already enabled'),
                          backgroundColor: AppConstants.successColor,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.successColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.defaultPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Notifications Enabled',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  )
                else if (_permissionStatus == AuthorizationStatus.denied)
                  Column(
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _openSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          padding: const EdgeInsets.symmetric(
                            vertical: AppConstants.defaultPadding,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppConstants.borderRadius,
                            ),
                          ),
                        ),
                        child: const Text(
                          'Open Settings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.defaultPadding),
                      TextButton(
                        onPressed: _isLoading ? null : _requestPermission,
                        child: const Text(
                          'Try Again',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: _isLoading ? null : _requestPermission,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.defaultPadding,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Enable Notifications',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),

                const SizedBox(height: AppConstants.largePadding),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppConstants.primaryColor, size: 24),
        ),
        const SizedBox(width: AppConstants.defaultPadding),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppConstants.subheadingStyle.copyWith(fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(description, style: AppConstants.captionStyle),
            ],
          ),
        ),
      ],
    );
  }
}
