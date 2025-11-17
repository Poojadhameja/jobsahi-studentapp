import 'package:equatable/equatable.dart';

/// Interviews states
abstract class InterviewsState extends Equatable {
  const InterviewsState();

  @override
  List<Object?> get props => [];
}

/// Initial interviews state
class InterviewsInitial extends InterviewsState {
  const InterviewsInitial();
}

/// Interviews loading state
class InterviewsLoading extends InterviewsState {
  const InterviewsLoading();
}

/// Interviews loaded state
class InterviewsLoaded extends InterviewsState {
  final List<Map<String, dynamic>> interviews;

  const InterviewsLoaded({required this.interviews});

  @override
  List<Object?> get props => [interviews];
}

/// Interviews error state
class InterviewsError extends InterviewsState {
  final String message;

  const InterviewsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Interview detail loading state
class InterviewDetailLoading extends InterviewsState {
  const InterviewDetailLoading();
}

/// Interview detail loaded state
class InterviewDetailLoaded extends InterviewsState {
  final Map<String, dynamic> interviewDetail;

  const InterviewDetailLoaded({required this.interviewDetail});

  @override
  List<Object?> get props => [interviewDetail];
}

/// Interview detail error state
class InterviewDetailError extends InterviewsState {
  final String message;

  const InterviewDetailError({required this.message});

  @override
  List<Object?> get props => [message];
}

