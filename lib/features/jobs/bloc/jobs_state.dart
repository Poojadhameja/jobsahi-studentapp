import 'package:equatable/equatable.dart';
import 'package:file_picker/file_picker.dart';

/// Jobs states
abstract class JobsState extends Equatable {
  const JobsState();
}

/// Initial jobs state
class JobsInitial extends JobsState {
  const JobsInitial();

  @override
  List<Object?> get props => [];
}

/// Jobs loading state
class JobsLoading extends JobsState {
  const JobsLoading();

  @override
  List<Object?> get props => [];
}

/// Jobs loaded state
class JobsLoaded extends JobsState {
  final List<Map<String, dynamic>> allJobs;
  final List<Map<String, dynamic>> filteredJobs;
  final List<Map<String, dynamic>> savedJobs;
  final List<Map<String, dynamic>> appliedJobs;
  final String searchQuery;
  final int selectedCategoryIndex;
  final int selectedFilterIndex;
  final Set<String> savedJobIds;

  const JobsLoaded({
    required this.allJobs,
    required this.filteredJobs,
    required this.savedJobs,
    required this.appliedJobs,
    this.searchQuery = '',
    this.selectedCategoryIndex = 0,
    this.selectedFilterIndex = 0,
    required this.savedJobIds,
  });

  @override
  List<Object?> get props => [
    allJobs,
    filteredJobs,
    savedJobs,
    appliedJobs,
    searchQuery,
    selectedCategoryIndex,
    selectedFilterIndex,
    savedJobIds,
  ];

  /// Copy with method for immutable state updates
  JobsLoaded copyWith({
    List<Map<String, dynamic>>? allJobs,
    List<Map<String, dynamic>>? filteredJobs,
    List<Map<String, dynamic>>? savedJobs,
    List<Map<String, dynamic>>? appliedJobs,
    String? searchQuery,
    int? selectedCategoryIndex,
    int? selectedFilterIndex,
    Set<String>? savedJobIds,
  }) {
    return JobsLoaded(
      allJobs: allJobs ?? this.allJobs,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      savedJobs: savedJobs ?? this.savedJobs,
      appliedJobs: appliedJobs ?? this.appliedJobs,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
      savedJobIds: savedJobIds ?? this.savedJobIds,
    );
  }
}

/// Jobs error state
class JobsError extends JobsState {
  final String message;

  const JobsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Job saved state
class JobSavedState extends JobsState {
  final String jobId;

  const JobSavedState({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Job unsaved state
class JobUnsavedState extends JobsState {
  final String jobId;

  const JobUnsavedState({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Job application success state
class JobApplicationSuccessState extends JobsState {
  final String jobId;

  const JobApplicationSuccessState({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Job details loaded state
class JobDetailsLoaded extends JobsState {
  final Map<String, dynamic> job;
  final bool isBookmarked;

  const JobDetailsLoaded({required this.job, required this.isBookmarked});

  @override
  List<Object?> get props => [job, isBookmarked];

  JobDetailsLoaded copyWith({Map<String, dynamic>? job, bool? isBookmarked}) {
    return JobDetailsLoaded(
      job: job ?? this.job,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

/// Detailed job information loaded state
class DetailedJobLoaded extends JobsState {
  final Map<String, dynamic> jobInfo;
  final Map<String, dynamic> companyInfo;
  final Map<String, dynamic> statistics;
  final bool isBookmarked;

  const DetailedJobLoaded({
    required this.jobInfo,
    required this.companyInfo,
    required this.statistics,
    required this.isBookmarked,
  });

  @override
  List<Object?> get props => [jobInfo, companyInfo, statistics, isBookmarked];

  DetailedJobLoaded copyWith({
    Map<String, dynamic>? jobInfo,
    Map<String, dynamic>? companyInfo,
    Map<String, dynamic>? statistics,
    bool? isBookmarked,
  }) {
    return DetailedJobLoaded(
      jobInfo: jobInfo ?? this.jobInfo,
      companyInfo: companyInfo ?? this.companyInfo,
      statistics: statistics ?? this.statistics,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}

/// Job bookmark toggled state
class JobBookmarkToggled extends JobsState {
  final String jobId;
  final bool isBookmarked;

  const JobBookmarkToggled({required this.jobId, required this.isBookmarked});

  @override
  List<Object?> get props => [jobId, isBookmarked];
}

/// Search results loaded state
class SearchResultsLoaded extends JobsState {
  final String searchQuery;
  final List<Map<String, dynamic>> filteredJobs;
  final int selectedFilterIndex;

  const SearchResultsLoaded({
    required this.searchQuery,
    required this.filteredJobs,
    required this.selectedFilterIndex,
  });

  @override
  List<Object?> get props => [searchQuery, filteredJobs, selectedFilterIndex];

  SearchResultsLoaded copyWith({
    String? searchQuery,
    List<Map<String, dynamic>>? filteredJobs,
    int? selectedFilterIndex,
  }) {
    return SearchResultsLoaded(
      searchQuery: searchQuery ?? this.searchQuery,
      filteredJobs: filteredJobs ?? this.filteredJobs,
      selectedFilterIndex: selectedFilterIndex ?? this.selectedFilterIndex,
    );
  }
}

/// Application tracker loaded state
class ApplicationTrackerLoaded extends JobsState {
  final List<Map<String, dynamic>> appliedJobs;
  final List<Map<String, dynamic>> interviewJobs;
  final List<Map<String, dynamic>> offerJobs;

  const ApplicationTrackerLoaded({
    required this.appliedJobs,
    required this.interviewJobs,
    required this.offerJobs,
  });

  @override
  List<Object?> get props => [appliedJobs, interviewJobs, offerJobs];
}

/// Application viewed state
class ApplicationViewed extends JobsState {
  final String applicationId;

  const ApplicationViewed({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}

/// Apply for more jobs state
class ApplyForMoreJobsState extends JobsState {
  const ApplyForMoreJobsState();

  @override
  List<Object?> get props => [];
}

/// Saved jobs loaded state
class SavedJobsLoaded extends JobsState {
  final List<Map<String, dynamic>> savedJobs;

  const SavedJobsLoaded({required this.savedJobs});

  @override
  List<Object?> get props => [savedJobs];

  SavedJobsLoaded copyWith({List<Map<String, dynamic>>? savedJobs}) {
    return SavedJobsLoaded(savedJobs: savedJobs ?? this.savedJobs);
  }
}

/// Saved job removed state
class SavedJobRemoved extends JobsState {
  final String jobId;

  const SavedJobRemoved({required this.jobId});

  @override
  List<Object?> get props => [jobId];
}

/// Job application form loaded state
class JobApplicationFormLoaded extends JobsState {
  final Map<String, dynamic> job;
  final Map<String, String> formData;
  final PlatformFile? resumeFile;

  const JobApplicationFormLoaded({
    required this.job,
    required this.formData,
    this.resumeFile,
  });

  @override
  List<Object?> get props => [job, formData, resumeFile];

  JobApplicationFormLoaded copyWith({
    Map<String, dynamic>? job,
    Map<String, String>? formData,
    PlatformFile? resumeFile,
  }) {
    return JobApplicationFormLoaded(
      job: job ?? this.job,
      formData: formData ?? this.formData,
      resumeFile: resumeFile ?? this.resumeFile,
    );
  }
}

/// Resume file picked state
class ResumeFilePicked extends JobsState {
  final PlatformFile resumeFile;

  const ResumeFilePicked({required this.resumeFile});

  @override
  List<Object?> get props => [resumeFile];
}

/// Resume file removed state
class ResumeFileRemoved extends JobsState {
  const ResumeFileRemoved();

  @override
  List<Object?> get props => [];
}

/// Job application submitting state
class JobApplicationSubmitting extends JobsState {
  const JobApplicationSubmitting();

  @override
  List<Object?> get props => [];
}

/// Job application submitted state
class JobApplicationSubmitted extends JobsState {
  final String applicationId;

  const JobApplicationSubmitted({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}

/// Calendar view loaded state
class CalendarViewLoaded extends JobsState {
  final DateTime selectedDate;
  final DateTime focusedDate;

  const CalendarViewLoaded({
    required this.selectedDate,
    required this.focusedDate,
  });

  @override
  List<Object?> get props => [selectedDate, focusedDate];

  CalendarViewLoaded copyWith({DateTime? selectedDate, DateTime? focusedDate}) {
    return CalendarViewLoaded(
      selectedDate: selectedDate ?? this.selectedDate,
      focusedDate: focusedDate ?? this.focusedDate,
    );
  }
}

/// Write review loaded state
class WriteReviewLoaded extends JobsState {
  final Map<String, dynamic> job;
  final int rating;
  final String reviewText;

  const WriteReviewLoaded({
    required this.job,
    required this.rating,
    required this.reviewText,
  });

  @override
  List<Object?> get props => [job, rating, reviewText];

  WriteReviewLoaded copyWith({
    Map<String, dynamic>? job,
    int? rating,
    String? reviewText,
  }) {
    return WriteReviewLoaded(
      job: job ?? this.job,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
    );
  }
}

/// Review submitted state
class ReviewSubmitted extends JobsState {
  final String reviewId;

  const ReviewSubmitted({required this.reviewId});

  @override
  List<Object?> get props => [reviewId];
}
