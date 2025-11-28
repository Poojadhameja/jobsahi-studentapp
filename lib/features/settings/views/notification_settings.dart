import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/services/fcm_service.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

/// Combined Notification Settings Page
/// This page combines both notification permission and notification preferences
class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final FcmService _fcmService = FcmService();
  bool _isLoading = false;
  AuthorizationStatus? _permissionStatus;
  Map<String, bool> _preferences = {
    'jobAlerts': true,
    'applicationUpdates': true,
    'messages': true,
    'promotional': false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissionStatus();
    // Load initial preferences from bloc
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
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

  void _savePreferences() {
    context.read<SettingsBloc>().add(
          UpdateNotificationPreferencesEvent(preferences: _preferences),
        );
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
          title: Text(
            'Notification Settings',
            style: AppConstants.headingStyle,
          ),
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
        body: BlocConsumer<SettingsBloc, SettingsState>(
          listener: (context, state) {
            if (state is NotificationPreferencesUpdatedState) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✅ Preferences saved successfully!'),
                  backgroundColor: AppConstants.successColor,
                  duration: Duration(seconds: 2),
                ),
              );
            } else if (state is SettingsError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppConstants.errorColor,
                  duration: const Duration(seconds: 2),
                ),
              );
            } else if (state is SettingsLoaded) {
              setState(() {
                _preferences = Map<String, bool>.from(
                  state.notificationPreferences,
                );
              });
            }
          },
          builder: (context, state) {
            final preferences = state is SettingsLoaded
                ? state.notificationPreferences
                : _preferences;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.largePadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppConstants.defaultPadding),

                    // ==================== PERMISSION SECTION ====================
                    _buildSectionHeader(
                      'Notification Permission',
                      Icons.notifications_outlined,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

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
                              _permissionStatus ==
                                          AuthorizationStatus.authorized ||
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

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Permission Action Button
                    if (_permissionStatus == AuthorizationStatus.authorized ||
                        _permissionStatus == AuthorizationStatus.provisional)
                      ElevatedButton(
                        onPressed: () {
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

                    const SizedBox(height: AppConstants.largePadding * 2),

                    // ==================== PREFERENCES SECTION ====================
                    _buildSectionHeader(
                      'Notification Preferences',
                      Icons.settings_outlined,
                    ),
                    const SizedBox(height: AppConstants.defaultPadding),

                    Text(
                      'Choose what notifications you want to receive',
                      style: AppConstants.bodyStyle.copyWith(
                        color: const Color(0xFF666666),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: AppConstants.largePadding),

                    // Job Alerts
                    _buildPreferenceTile(
                      context,
                      icon: Icons.work_outline,
                      title: 'Job Alerts',
                      subtitle: 'Get notified about new job opportunities',
                      value: preferences['jobAlerts'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _preferences['jobAlerts'] = value;
                        });
                        _savePreferences();
                      },
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Application Updates
                    _buildPreferenceTile(
                      context,
                      icon: Icons.update_outlined,
                      title: 'Application Updates',
                      subtitle: 'Stay informed about your application status',
                      value: preferences['applicationUpdates'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _preferences['applicationUpdates'] = value;
                        });
                        _savePreferences();
                      },
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Messages
                    _buildPreferenceTile(
                      context,
                      icon: Icons.message_outlined,
                      title: 'Messages',
                      subtitle: 'Receive messages from employers',
                      value: preferences['messages'] ?? true,
                      onChanged: (value) {
                        setState(() {
                          _preferences['messages'] = value;
                        });
                        _savePreferences();
                      },
                    ),

                    const SizedBox(height: AppConstants.defaultPadding),

                    // Promotional
                    _buildPreferenceTile(
                      context,
                      icon: Icons.local_offer_outlined,
                      title: 'Promotional',
                      subtitle: 'Receive offers and promotional content',
                      value: preferences['promotional'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          _preferences['promotional'] = value;
                        });
                        _savePreferences();
                      },
                    ),

                    const SizedBox(height: AppConstants.largePadding * 2),

                    // View History Button
                    ElevatedButton.icon(
                      onPressed: () {
                        context.push(AppRoutes.notificationHistory);
                      },
                      icon: const Icon(Icons.history, color: Colors.white),
                      label: const Text(
                        'View Notification History',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
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
                    ),

                    const SizedBox(height: AppConstants.largePadding),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppConstants.primaryColor, size: 24),
        const SizedBox(width: AppConstants.defaultPadding),
        Text(
          title,
          style: AppConstants.headingStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppConstants.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppConstants.primaryColor,
              size: 24,
            ),
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
                Text(
                  subtitle,
                  style: AppConstants.captionStyle,
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppConstants.primaryColor,
          ),
        ],
      ),
    );
  }
}

