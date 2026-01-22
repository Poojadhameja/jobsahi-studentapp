import 'package:equatable/equatable.dart';
import '../models/campus_drive.dart';

enum CampusDriveStatus { initial, loading, success, failure }

/// Unified Campus Drive State
class CampusDriveState extends Equatable {
  final CampusDriveStatus status;
  final List<CampusDrive> liveDrives;
  final List<CampusApplication> myApplications;
  final CampusDriveDetails? selectedDriveDetails;
  final CampusApplication? selectedApplicationDetails;
  final String? errorMessage;
  
  // Specific loading states to prevent full UI blocking
  final bool isLiveDrivesLoading;
  final bool isMyApplicationsLoading;
  final bool isDetailsLoading;

  const CampusDriveState({
    this.status = CampusDriveStatus.initial,
    this.liveDrives = const [],
    this.myApplications = const [],
    this.selectedDriveDetails,
    this.selectedApplicationDetails,
    this.errorMessage,
    this.isLiveDrivesLoading = false,
    this.isMyApplicationsLoading = false,
    this.isDetailsLoading = false,
  });

  CampusDriveState copyWith({
    CampusDriveStatus? status,
    List<CampusDrive>? liveDrives,
    List<CampusApplication>? myApplications,
    CampusDriveDetails? selectedDriveDetails,
    CampusApplication? selectedApplicationDetails,
    String? errorMessage,
    bool? isLiveDrivesLoading,
    bool? isMyApplicationsLoading,
    bool? isDetailsLoading,
  }) {
    return CampusDriveState(
      status: status ?? this.status,
      liveDrives: liveDrives ?? this.liveDrives,
      myApplications: myApplications ?? this.myApplications,
      selectedDriveDetails: selectedDriveDetails ?? this.selectedDriveDetails,
      selectedApplicationDetails: selectedApplicationDetails ?? this.selectedApplicationDetails,
      errorMessage: errorMessage ?? this.errorMessage,
      isLiveDrivesLoading: isLiveDrivesLoading ?? this.isLiveDrivesLoading,
      isMyApplicationsLoading: isMyApplicationsLoading ?? this.isMyApplicationsLoading,
      isDetailsLoading: isDetailsLoading ?? this.isDetailsLoading,
    );
  }

  @override
  List<Object?> get props => [
        status,
        liveDrives,
        myApplications,
        selectedDriveDetails,
        selectedApplicationDetails,
        errorMessage,
        isLiveDrivesLoading,
        isMyApplicationsLoading,
        isDetailsLoading,
      ];
}
