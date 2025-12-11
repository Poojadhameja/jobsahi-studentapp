import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/utils/app_constants.dart';
import '../../../core/constants/app_routes.dart';
import '../../../shared/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationHistoryPage extends StatefulWidget {
  const NotificationHistoryPage({super.key});

  @override
  State<NotificationHistoryPage> createState() =>
      _NotificationHistoryPageState();
}

class _NotificationHistoryPageState extends State<NotificationHistoryPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<NotificationModel> _notifications = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user is logged in
      final isLoggedIn = await _apiService.isLoggedIn();
      if (!isLoggedIn) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to view notifications';
        });
        return;
      }

      // Fetch notifications from API
      final response = await _apiService.get(
        AppConstants.getNotificationsEndpoint,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        
        if (responseData is Map<String, dynamic>) {
          final notificationsResponse =
              NotificationsResponse.fromJson(responseData);
          
          if (notificationsResponse.status) {
            setState(() {
              _notifications = notificationsResponse.data;
              _isLoading = false;
            });
          } else {
            setState(() {
              _isLoading = false;
              _errorMessage = notificationsResponse.message.isNotEmpty
                  ? notificationsResponse.message
                  : 'Failed to load notifications';
            });
          }
        } else {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Invalid response format';
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load notifications';
        });
      }
    } catch (e) {
      debugPrint('🔴 Error loading notifications: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading notifications: ${e.toString()}';
      });
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      final response = await _apiService.patch(
        AppConstants.markNotificationReadEndpoint,
        queryParameters: {'id': notificationId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          final status = responseData['status'] as bool? ?? false;
          if (status) {
            // Update local state
            setState(() {
              final index = _notifications.indexWhere(
                (n) => n.id == notificationId,
              );
              if (index != -1) {
                _notifications[index] = NotificationModel(
                  id: _notifications[index].id,
                  senderId: _notifications[index].senderId,
                  senderRole: _notifications[index].senderRole,
                  message: _notifications[index].message,
                  type: _notifications[index].type,
                  createdAt: _notifications[index].createdAt,
                  isRead: true,
                );
              }
            });
          }
        }
      }
    } catch (e) {
      debugPrint('🔴 Error marking notification as read: $e');
    }
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read if not already read
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }

    // Navigate based on type
    // Note: Backend response doesn't include job_id in notification data
    // You may need to extract it from message or add it to backend response
    switch (notification.type) {
      case 'new_job':
        context.push(AppRoutes.home);
        break;
      case 'shortlisted':
        context.push(AppRoutes.applicationTracker);
        break;
      case 'message':
        // Messages feature removed - redirect to home
        context.push(AppRoutes.home);
        break;
      default:
        context.push(AppRoutes.home);
        break;
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
          title: Text(
            'Notification History',
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
          actions: [
            IconButton(
              icon: const Icon(
                Icons.refresh,
                color: AppConstants.textPrimaryColor,
              ),
              onPressed: _loadNotifications,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppConstants.primaryColor,
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.red.shade300,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Text(
                          _errorMessage!,
                          style: AppConstants.headingStyle.copyWith(
                            color: Colors.red.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        ElevatedButton(
                          onPressed: _loadNotifications,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
            : _notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 80,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: AppConstants.defaultPadding),
                        Text(
                          'No notifications yet',
                          style: AppConstants.headingStyle.copyWith(
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: AppConstants.smallPadding),
                        Text(
                          'You\'ll see your notifications here',
                          style: AppConstants.captionStyle,
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadNotifications,
                    color: AppConstants.primaryColor,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(AppConstants.defaultPadding),
                      itemCount: _notifications.length,
                      itemBuilder: (context, index) {
                        final notification = _notifications[index];
                        return _buildNotificationItem(notification);
                      },
                    ),
                  ),
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      child: Material(
        color: notification.isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: InkWell(
          onTap: () => _handleNotificationTap(notification),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getIconColor(notification.type)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIcon(notification.type),
                    color: _getIconColor(notification.type),
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppConstants.defaultPadding),
                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _getNotificationTitle(notification),
                              style: AppConstants.subheadingStyle.copyWith(
                                fontSize: 16,
                                fontWeight: notification.isRead
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppConstants.primaryColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppConstants.captionStyle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: AppConstants.captionStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getNotificationTitle(NotificationModel notification) {
    switch (notification.type) {
      case 'new_job':
        return 'New Job Posted';
      case 'shortlisted':
        return 'Application Update';
      case 'general':
        return 'Notification';
      case 'system':
        return 'System Update';
      case 'reminder':
        return 'Reminder';
      case 'alert':
        return 'Alert';
      default:
        return 'Notification';
    }
  }

  IconData _getIcon(String? type) {
    switch (type) {
      case 'new_job':
        return Icons.work_outline;
      case 'shortlisted':
        return Icons.check_circle_outline;
      case 'message':
        return Icons.message_outlined;
      case 'system':
        return Icons.settings_outlined;
      case 'reminder':
        return Icons.alarm_outlined;
      case 'alert':
        return Icons.warning_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String? type) {
    switch (type) {
      case 'new_job':
        return AppConstants.primaryColor;
      case 'shortlisted':
        return AppConstants.successColor;
      case 'message':
        return Colors.blue;
      case 'system':
        return Colors.orange;
      case 'reminder':
        return Colors.purple;
      case 'alert':
        return Colors.red;
      default:
        return AppConstants.primaryColor;
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}


