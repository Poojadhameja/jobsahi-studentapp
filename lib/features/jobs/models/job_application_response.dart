class JobApplicationResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  const JobApplicationResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) {
    final successFlag = json['success'];
    final statusFlag = json['status'];
    final isSuccess = successFlag == true ||
        successFlag == 1 ||
        successFlag == '1' ||
        (successFlag is String && successFlag.toLowerCase() == 'true') ||
        statusFlag == true ||
        statusFlag == 1 ||
        statusFlag == '1' ||
        (statusFlag is String && statusFlag.toLowerCase() == 'true');

    return JobApplicationResponse(
      success: isSuccess,
      message: json['message']?.toString() ?? '',
      data: json['data'] is Map<String, dynamic>
          ? json['data'] as Map<String, dynamic>
          : null,
    );
  }
}

