import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class NotificationPreferencesPage extends StatefulWidget {
  const NotificationPreferencesPage({super.key});

  @override
  State<NotificationPreferencesPage> createState() =>
      _NotificationPreferencesPageState();
}

class _NotificationPreferencesPageState
    extends State<NotificationPreferencesPage> {
  Map<String, bool> _preferences = {
    'jobAlerts': true,
    'applicationUpdates': true,
    'messages': true,
    'promotional': false,
  };

  @override
  void initState() {
    super.initState();
    // Load initial preferences from bloc
    context.read<SettingsBloc>().add(const LoadSettingsEvent());
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
            'Notification Preferences',
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
                _preferences = Map<String, bool>.from(state.notificationPreferences);
              });
            }
          },
          builder: (context, state) {
            if (state is SettingsLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              );
            }

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

                    // Description
                    Text(
                      'Choose what notifications you want to receive',
                      style: AppConstants.bodyStyle.copyWith(
                        color: const Color(0xFF666666),
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: AppConstants.largePadding * 2),

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
                  ],
                ),
              ),
            );
          },
        ),
      ),
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

  void _savePreferences() {
    context.read<SettingsBloc>().add(
          UpdateNotificationPreferencesEvent(preferences: _preferences),
        );
  }
}

