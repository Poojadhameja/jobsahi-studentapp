class ProfileUpdateResponse {
  final bool status;
  final bool success;
  final String message;
  final Map<String, dynamic> data;
  final Map<String, dynamic> meta;

  const ProfileUpdateResponse({
    required this.status,
    required this.success,
    required this.message,
    required this.data,
    required this.meta,
  });

  bool get isSuccessful => status || success;

  factory ProfileUpdateResponse.fromJson(Map<String, dynamic> json) {
    final statusValue = _normalizeBool(json['status']);
    final successValue = _normalizeBool(json['success']);
    final messageValue = json['message']?.toString() ?? '';
    final dataValue =
        (json['data'] as Map<String, dynamic>?) ?? <String, dynamic>{};
    final metaValue =
        (json['meta'] as Map<String, dynamic>?) ?? <String, dynamic>{};

    return ProfileUpdateResponse(
      status: statusValue,
      success: successValue,
      message: messageValue,
      data: dataValue,
      meta: metaValue,
    );
  }

  static bool _normalizeBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }
    if (value is String) {
      final normalized = value.trim().toLowerCase();
      return normalized == 'true' || normalized == '1' || normalized == 'yes';
    }
    return false;
  }
}
