/// Notification model based on backend API response
class NotificationModel {
  final int id;
  final int? senderId;
  final String? senderRole;
  final String message;
  final String? type;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    this.senderId,
    this.senderRole,
    required this.message,
    this.type,
    required this.createdAt,
    required this.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      senderId: json['sender_id'] as int?,
      senderRole: json['sender_role'] as String?,
      message: json['message'] as String? ?? '',
      type: json['type'] as String?,
      createdAt: _parseDateTime(json['created_at'] as String?),
      isRead: (json['is_read'] as int? ?? 0) == 1,
    );
  }

  static DateTime _parseDateTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return DateTime.now();
    }
    try {
      // Parse format: "2025-09-30 16:39:11"
      return DateTime.parse(dateString.replaceAll(' ', 'T'));
    } catch (e) {
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender_id': senderId,
      'sender_role': senderRole,
      'message': message,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead ? 1 : 0,
    };
  }
}

/// Notification API Response model
class NotificationsResponse {
  final bool status;
  final List<NotificationModel> data;
  final String message;

  NotificationsResponse({
    required this.status,
    required this.data,
    required this.message,
  });

  factory NotificationsResponse.fromJson(Map<String, dynamic> json) {
    return NotificationsResponse(
      status: json['status'] as bool? ?? false,
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => NotificationModel.fromJson(
                    item as Map<String, dynamic>,
                  ))
              .toList() ??
          [],
      message: json['message'] as String? ?? '',
    );
  }
}

