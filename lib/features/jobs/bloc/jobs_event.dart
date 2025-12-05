import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

/// Jobs events
abstract class JobsEvent extends Equatable {
  const JobsEvent();
}

/// Load jobs event
class LoadJobsEvent extends JobsEvent {
  const LoadJobsEvent();

  @override
  List<Object?> get props => [];
}

/// Search jobs event
class SearchJobsEvent extends JobsEvent {
  final String query;

  const SearchJobsEvent({required this.query});

  @override
  List<Object?> get props => [query];
}

/// Filter jobs event
class FilterJobsEvent extends JobsEvent {
  final String category;

  const FilterJobsEvent({required this.category});

  @override
  List<Object?> get props => [category];
}

/// Toggle filters event
class ToggleFiltersEvent extends JobsEvent {
  const ToggleFiltersEvent();

  @override
  List<Object?> get props => [];
}

/// Save job event
class SaveJobEvent extends JobsEvent {
  final String jobId;

  const SaveJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Unsave job event
class UnsaveJobEvent extends JobsEvent {
  final String jobId;

  const UnsaveJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Apply for job event
class ApplyForJobEvent extends JobsEvent {
  final String jobId;

  const ApplyForJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Load saved jobs event
class LoadSavedJobsEvent extends JobsEvent {
  final int? limit;
  final int? offset;

  const LoadSavedJobsEvent({this.limit, this.offset});

  @override
  List<Object?> get props => [limit, offset];
}

/// Load applied jobs event
class LoadAppliedJobsEvent extends JobsEvent {
  const LoadAppliedJobsEvent();

  @override
  List<Object?> get props => [];
}

/// Refresh jobs event
class RefreshJobsEvent extends JobsEvent {
  const RefreshJobsEvent();

  @override
  List<Object?> get props => [];
}

/// Clear search event
class ClearSearchEvent extends JobsEvent {
  const ClearSearchEvent();

  @override
  List<Object?> get props => [];
}

/// Load job details event
class LoadJobDetailsEvent extends JobsEvent {
  final String jobId;

  const LoadJobDetailsEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Toggle job bookmark event
class ToggleJobBookmarkEvent extends JobsEvent {
  final String jobId;

  const ToggleJobBookmarkEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Load search results event
class LoadSearchResultsEvent extends JobsEvent {
  final String searchQuery;

  const LoadSearchResultsEvent({required this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

/// Load application tracker data event
class LoadApplicationTrackerEvent extends JobsEvent {
  const LoadApplicationTrackerEvent();

  @override
  List<Object?> get props => [];
}

/// View application event
class ViewApplicationEvent extends JobsEvent {
  final String applicationId;

  const ViewApplicationEvent({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}

/// Apply for more jobs event
class ApplyForMoreJobsEvent extends JobsEvent {
  const ApplyForMoreJobsEvent();

  @override
  List<Object?> get props => [];
}

/// Remove saved job event
class RemoveSavedJobEvent extends JobsEvent {
  final String jobId;

  const RemoveSavedJobEvent({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Load job application form event
class LoadJobApplicationFormEvent extends JobsEvent {
  final Map<String, dynamic> job;

  const LoadJobApplicationFormEvent({required this.job});

  @override
  List<Object?> get props => [job];
}

/// Update job application form event
class UpdateJobApplicationFormEvent extends JobsEvent {
  final String field;
  final String value;

  const UpdateJobApplicationFormEvent({
    required this.field,
    required this.value,
  });

  @override
  List<Object?> get props => [field, value];
}

/// Pick resume file event
class PickResumeFileEvent extends JobsEvent {
  const PickResumeFileEvent();

  @override
  List<Object?> get props => [];
}

/// Remove resume file event
class RemoveResumeFileEvent extends JobsEvent {
  const RemoveResumeFileEvent();

  @override
  List<Object?> get props => [];
}

/// Submit job application event
class SubmitJobApplicationEvent extends JobsEvent {
  final Map<String, dynamic> formData;
  final PlatformFile? resumeFile;

  const SubmitJobApplicationEvent({required this.formData, this.resumeFile});

  @override
  List<Object?> get props => [formData, resumeFile];
}

/// Load calendar view event
class LoadCalendarViewEvent extends JobsEvent {
  const LoadCalendarViewEvent();

  @override
  List<Object?> get props => [];
}

/// Change calendar month event
class ChangeCalendarMonthEvent extends JobsEvent {
  final DateTime newFocusedDate;

  const ChangeCalendarMonthEvent({required this.newFocusedDate});

  @override
  List<Object?> get props => [newFocusedDate];
}

/// Select calendar date event
class SelectCalendarDateEvent extends JobsEvent {
  final DateTime selectedDate;

  const SelectCalendarDateEvent({required this.selectedDate});

  @override
  List<Object?> get props => [selectedDate];
}

/// Load write review event
class LoadWriteReviewEvent extends JobsEvent {
  final Map<String, dynamic> job;

  const LoadWriteReviewEvent({required this.job});

  @override
  List<Object?> get props => [job];
}

/// Update review rating event
class UpdateReviewRatingEvent extends JobsEvent {
  final int rating;

  const UpdateReviewRatingEvent({required this.rating});

  @override
  List<Object?> get props => [rating];
}

/// Update review text event
class UpdateReviewTextEvent extends JobsEvent {
  final String text;

  const UpdateReviewTextEvent({required this.text});

  @override
  List<Object?> get props => [text];
}

/// Submit review event
class SubmitReviewEvent extends JobsEvent {
  final Map<String, dynamic> reviewData;

  const SubmitReviewEvent({required this.reviewData});

  @override
  List<Object?> get props => [reviewData];
}
