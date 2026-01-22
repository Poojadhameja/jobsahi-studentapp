import 'package:equatable/equatable.dart';

/// Base class for all campus drive events
abstract class CampusDriveEvent extends Equatable {
  const CampusDriveEvent();

  @override
  List<Object?> get props => [];
}

/// Load live campus drives
class LoadLiveDrivesEvent extends CampusDriveEvent {
  final bool forceRefresh;

  const LoadLiveDrivesEvent({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

/// Load campus drive details
class LoadDriveDetailsEvent extends CampusDriveEvent {
  final int driveId;

  const LoadDriveDetailsEvent(this.driveId);

  @override
  List<Object?> get props => [driveId];
}

/// Apply to campus drive
class ApplyToDriveEvent extends CampusDriveEvent {
  final int driveId;
  final List<Map<String, dynamic>> preferences;

  const ApplyToDriveEvent({
    required this.driveId,
    required this.preferences,
  });

  @override
  List<Object?> get props => [driveId, preferences];
}

/// Load my applications
class LoadMyApplicationsEvent extends CampusDriveEvent {
  const LoadMyApplicationsEvent();
}

/// Load application details
class LoadApplicationDetailsEvent extends CampusDriveEvent {
  final int applicationId;

  const LoadApplicationDetailsEvent(this.applicationId);

  @override
  List<Object?> get props => [applicationId];
}

/// Refresh live drives
class RefreshLiveDrivesEvent extends CampusDriveEvent {
  const RefreshLiveDrivesEvent();
}

/// Clear error state
class ClearCampusDriveErrorEvent extends CampusDriveEvent {
  const ClearCampusDriveErrorEvent();
}

/// Delete preference from application
class DeletePreferenceEvent extends CampusDriveEvent {
  final int applicationId;
  final int preferenceNumber;

  const DeletePreferenceEvent({
    required this.applicationId,
    required this.preferenceNumber,
  });

  @override
  List<Object?> get props => [applicationId, preferenceNumber];
}
