/// Feedback request model
class FeedbackRequest {
  final String feedback;
  final String? subject;

  FeedbackRequest({
    required this.feedback,
    this.subject,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'feedback': feedback,
    };
    if (subject != null && subject!.isNotEmpty) {
      json['subject'] = subject;
    }
    return json;
  }
}

/// Feedback response model
class FeedbackResponse {
  final bool status;
  final String message;
  final int? feedbackId;

  FeedbackResponse({
    required this.status,
    required this.message,
    this.feedbackId,
  });

  factory FeedbackResponse.fromJson(Map<String, dynamic> json) {
    return FeedbackResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      feedbackId: json['feedback_id'] as int?,
    );
  }
}

/// Rate limit error response model
class RateLimitErrorResponse {
  final bool status;
  final String message;
  final String? messageEn;
  final int? submissionsInWindow;
  final String? windowStartDate;
  final String? resetDate;
  final int? remainingDays;

  RateLimitErrorResponse({
    required this.status,
    required this.message,
    this.messageEn,
    this.submissionsInWindow,
    this.windowStartDate,
    this.resetDate,
    this.remainingDays,
  });

  factory RateLimitErrorResponse.fromJson(Map<String, dynamic> json) {
    return RateLimitErrorResponse(
      status: json['status'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      messageEn: json['message_en'] as String?,
      submissionsInWindow: json['submissions_in_window'] as int?,
      windowStartDate: json['window_start_date'] as String?,
      resetDate: json['reset_date'] as String?,
      remainingDays: json['remaining_days'] as int?,
    );
  }
}

