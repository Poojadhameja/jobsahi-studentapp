import 'package:equatable/equatable.dart';

/// Interviews events
abstract class InterviewsEvent extends Equatable {
  const InterviewsEvent();

  @override
  List<Object?> get props => [];
}

/// Load interviews event
class LoadInterviewsEvent extends InterviewsEvent {
  final String? status;
  final String? type;

  const LoadInterviewsEvent({
    this.status,
    this.type,
  });

  @override
  List<Object?> get props => [status, type];
}

/// Refresh interviews event
class RefreshInterviewsEvent extends InterviewsEvent {
  final String? status;
  final String? type;

  const RefreshInterviewsEvent({
    this.status,
    this.type,
  });

  @override
  List<Object?> get props => [status, type];
}

/// Load interview detail event
class LoadInterviewDetailEvent extends InterviewsEvent {
  final int interviewId;

  const LoadInterviewDetailEvent({required this.interviewId});

  @override
  List<Object?> get props => [interviewId];
}

