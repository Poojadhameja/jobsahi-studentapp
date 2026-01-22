import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import '../../../core/utils/network_error_helper.dart';
import '../repository/campus_drive_repository.dart';
import '../models/campus_application.dart';
import 'campus_drive_event.dart';
import 'campus_drive_state.dart';

/// Campus Drive BLoC
/// Handles all campus drive-related business logic
class CampusDriveBloc extends Bloc<CampusDriveEvent, CampusDriveState> {
  final CampusDriveRepository _repository;

  CampusDriveBloc({required CampusDriveRepository repository})
      : _repository = repository,
        super(const CampusDriveState()) {
    // Register event handlers
    on<LoadLiveDrivesEvent>(_onLoadLiveDrives);
    on<LoadDriveDetailsEvent>(_onLoadDriveDetails);
    on<ApplyToDriveEvent>(_onApplyToDrive);
    on<RefreshLiveDrivesEvent>(_onRefreshLiveDrives);
  on<LoadMyApplicationsEvent>(_onLoadMyApplications);
  on<LoadApplicationDetailsEvent>(_onLoadApplicationDetails);
  on<ClearCampusDriveErrorEvent>(_onClearError);
  on<DeletePreferenceEvent>(_onDeletePreference);
  }

  /// Handle load live drives
  Future<void> _onLoadLiveDrives(
    LoadLiveDrivesEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isLiveDrivesLoading: true,
        errorMessage: null,
      ));
      
      final drives = await _repository.getLiveDrives();
      
      emit(state.copyWith(
        status: CampusDriveStatus.success,
        liveDrives: drives,
        isLiveDrivesLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error loading live drives: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isLiveDrivesLoading: false,
      ));
    }
  }

  /// Handle refresh live drives
  Future<void> _onRefreshLiveDrives(
    RefreshLiveDrivesEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      // Don't show full screen loading for refresh
      // emit(state.copyWith(isLiveDrivesLoading: true));
      
      final drives = await _repository.getLiveDrives();
      
      emit(state.copyWith(
        status: CampusDriveStatus.success,
        liveDrives: drives,
        // isLiveDrivesLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error refreshing live drives: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        // isLiveDrivesLoading: false,
      ));
    }
  }

  /// Handle load my applications
  Future<void> _onLoadMyApplications(
    LoadMyApplicationsEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isMyApplicationsLoading: true,
        errorMessage: null,
      ));
      
      final applications = await _repository.getMyApplications();
      
      emit(state.copyWith(
        status: CampusDriveStatus.success,
        myApplications: applications,
        isMyApplicationsLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error loading my applications: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isMyApplicationsLoading: false,
      ));
    }
  }

  /// Handle load application details
  Future<void> _onLoadApplicationDetails(
    LoadApplicationDetailsEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isDetailsLoading: true,
        errorMessage: null,
      ));
      
      final application = await _repository.getApplicationDetails(event.applicationId);
      
      emit(state.copyWith(
        status: CampusDriveStatus.success,
        selectedApplicationDetails: application,
        isDetailsLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error loading application details: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isDetailsLoading: false,
      ));
    }
  }

  /// Handle load drive details
  Future<void> _onLoadDriveDetails(
    LoadDriveDetailsEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isDetailsLoading: true,
        errorMessage: null,
      ));
      
      final details = await _repository.getDriveDetails(event.driveId);
      
      emit(state.copyWith(
        status: CampusDriveStatus.success,
        selectedDriveDetails: details,
        isDetailsLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error loading drive details: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isDetailsLoading: false,
      ));
    }
  }

  /// Handle apply to drive
  Future<void> _onApplyToDrive(
    ApplyToDriveEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isDetailsLoading: true,
        errorMessage: null,
      ));
      
      await _repository.applyToDrive(
        driveId: event.driveId,
        preferences: event.preferences,
      );
      
      // After successful application, reload the drive details to show updated status
      final details = await _repository.getDriveDetails(event.driveId);
      
      // Also reload my applications list to reflect the new application
      // We don't await this to keep UI responsive, or we can emit it later
      add(const LoadMyApplicationsEvent());
      add(const LoadLiveDrivesEvent(forceRefresh: true));

      emit(state.copyWith(
        status: CampusDriveStatus.success,
        selectedDriveDetails: details,
        isDetailsLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error applying to drive: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isDetailsLoading: false,
      ));
    }
  }

  /// Handle clear error
  Future<void> _onClearError(
    ClearCampusDriveErrorEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    emit(state.copyWith(
      errorMessage: null,
      status: CampusDriveStatus.initial,
    ));
  }

  /// Handle delete preference
  Future<void> _onDeletePreference(
    DeletePreferenceEvent event,
    Emitter<CampusDriveState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: CampusDriveStatus.loading,
        isDetailsLoading: true,
        errorMessage: null,
      ));
      
      final updatedApplication = await _repository.deletePreference(
        applicationId: event.applicationId,
        preferenceNumber: event.preferenceNumber,
      );
      
      // Update the application in the list
      final updatedApplications = state.myApplications.map((app) {
        if (app.id == updatedApplication.id) {
          return updatedApplication;
        }
        return app;
      }).toList();
      
      // Also update the selected application details if it matches
      CampusApplication? updatedSelectedApplication;
      if (state.selectedApplicationDetails?.id == updatedApplication.id) {
        updatedSelectedApplication = updatedApplication;
      }

      emit(state.copyWith(
        status: CampusDriveStatus.success,
        myApplications: updatedApplications,
        selectedApplicationDetails: updatedSelectedApplication,
        isDetailsLoading: false,
      ));
    } catch (e) {
      debugPrint('🔴 [Campus Drive] Error deleting preference: $e');
      final errorMessage = NetworkErrorHelper.extractErrorMessage(e);
      emit(state.copyWith(
        status: CampusDriveStatus.failure,
        errorMessage: errorMessage,
        isDetailsLoading: false,
      ));
    }
  }
}
