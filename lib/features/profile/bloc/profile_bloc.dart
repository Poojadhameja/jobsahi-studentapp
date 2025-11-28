import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import '../../../shared/data/user_data.dart';
import '../../../shared/services/api_service.dart';
import '../../../shared/services/location_service.dart';
import '../../../shared/services/token_storage.dart';
import '../../../shared/services/profile_cache_service.dart';
import '../../../core/utils/network_error_helper.dart';
import '../models/student_profile.dart';

/// Profile BLoC
/// Handles all profile-related business logic with proper caching
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ApiService _apiService = ApiService();
  final TokenStorage _tokenStorage = TokenStorage.instance;
  final LocationService _locationService = LocationService.instance;
  final ProfileCacheService _cacheService = ProfileCacheService.instance;
  int _statusMessageCounter = 0;

  ProfileBloc() : super(const ProfileInitial()) {
    // Register event handlers
    on<LoadProfileDataEvent>(_onLoadProfileData);
    on<UpdateProfileEvent>(_onUpdateProfile);
    on<UpdateProfileImageEvent>(_onUpdateProfileImage);
    on<UpdateJobPreferencesEvent>(_onUpdateJobPreferences);
    on<UpdateSkillsEvent>(_onUpdateSkills);
    on<UpdateEducationEvent>(_onUpdateEducation);
    on<UpdateExperienceEvent>(_onUpdateExperience);
    on<DeleteExperienceEvent>(_onDeleteExperience);
    on<UpdateProfileHeaderInlineEvent>(_onInlineProfileHeaderUpdate);
    on<UpdateProfileResumeInlineEvent>(_onInlineResumeUpdate);
    on<UpdateProfileContactInlineEvent>(_onInlineContactUpdate);
    on<UpdateProfileGeneralInfoInlineEvent>(_onInlineGeneralInfoUpdate);
    on<UpdateProfileSocialLinksInlineEvent>(_onInlineSocialLinksUpdate);
    on<UpdateProfileCertificatesInlineEvent>(_onInlineCertificatesUpdate);
    on<UpdateProfileSkillsInlineEvent>(_onInlineSkillsUpdate);
    on<UpdateProfileExperienceListEvent>(_onInlineExperienceUpdate);
    on<UpdateProfileEducationListEvent>(_onInlineEducationUpdate);
    on<RefreshProfileDataEvent>(_onRefreshProfileData);
    on<ToggleSectionEvent>(_onToggleSection);
    on<DeleteCertificateEvent>(_onDeleteCertificate);
    on<RemoveProfileImageEvent>(_onRemoveProfileImage);
    on<UpdateJobTypeEvent>(_onUpdateJobType);
    on<UpdateExperienceLevelEvent>(_onUpdateExperienceLevel);
    on<UpdatePreferredLocationEvent>(_onUpdatePreferredLocation);
    on<UpdateSelectedTradeEvent>(_onUpdateSelectedTrade);
    on<UpdateSelectedStateEvent>(_onUpdateSelectedState);
    on<UpdateSelectedCityEvent>(_onUpdateSelectedCity);
    on<UpdateSelectedSalaryRangeEvent>(_onUpdateSelectedSalaryRange);
    on<UpdateAvailabilityEvent>(_onUpdateAvailability);
    on<ToggleJobSectorEvent>(_onToggleJobSector);
    on<ToggleJobTypeEvent>(_onToggleJobType);
    on<AddSkillEvent>(_onAddSkill);
    on<RemoveSkillEvent>(_onRemoveSkill);
    on<UpdateSearchQueryEvent>(_onUpdateSearchQuery);
    on<SelectLocationEvent>(_onSelectLocation);
    on<RequestLocationPermissionEvent>(_onRequestLocationPermission);
    on<LocationPermissionGrantedEvent>(_onLocationPermissionGranted);
    on<LocationPermissionDeniedEvent>(_onLocationPermissionDenied);
    on<ChangeJobStatusTabEvent>(_onChangeJobStatusTab);
    on<UpdateProfileEditFormEvent>(_onUpdateProfileEditForm);
    on<SaveProfileChangesEvent>(_onSaveProfileChanges);
    on<UpdateSkillsListEvent>(_onUpdateSkillsList);
    on<SaveSkillsChangesEvent>(_onSaveSkillsChanges);
  }

  /// Handle load profile data with caching support
  Future<void> _onLoadProfileData(
    LoadProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      // Initialize cache service
      await _cacheService.initialize();
      
      // Check cache first (unless force refresh)
      Map<String, dynamic>? cachedData;
      bool useCache = false;
      
      if (!event.forceRefresh) {
        final isCacheValid = await _cacheService.isCacheValid(maxAgeHours: 24);
        if (isCacheValid) {
          cachedData = await _cacheService.getProfileData();
          if (cachedData != null && cachedData.isNotEmpty) {
            useCache = true;
            debugPrint('✅ [ProfileBloc] Using cached profile data');
            
            // Emit cached data immediately
            emit(
              ProfileDetailsLoaded(
                userProfile: Map<String, dynamic>.from(
                  cachedData['userProfile'] ?? {},
                ),
                skills: List<String>.from(cachedData['skills'] ?? []),
                education: List<Map<String, dynamic>>.from(
                  cachedData['education'] ?? [],
                ),
                experience: List<Map<String, dynamic>>.from(
                  cachedData['experience'] ?? [],
                ),
                jobPreferences: Map<String, dynamic>.from(
                  cachedData['jobPreferences'] ?? {},
                ),
                sectionExpansionStates: {
                  'profile': false,
                  'summary': false,
                  'education': false,
                  'skills': false,
                  'experience': false,
                  'resume': false,
                  'certificates': false,
                  'contact': false,
                  'general_info': false,
                  'social': false,
                },
                certificates: List<Map<String, dynamic>>.from(
                  cachedData['certificates'] ?? [],
                ),
                profileImagePath: cachedData['profileImagePath'],
                profileImageName: cachedData['profileImageName'],
                resumeFileName: cachedData['resumeFileName'],
                lastResumeUpdatedDate: cachedData['lastResumeUpdatedDate'],
                resumeFileSize: cachedData['resumeFileSize'] ?? 0,
                resumeDownloadUrl: cachedData['resumeDownloadUrl'],
                isSyncing: false,
                statusMessage: null,
                statusIsError: false,
                statusMessageKey: 0,
              ),
            );
          }
        }
      }
      
      // If force refresh or no cache, show loading
      if (event.forceRefresh || !useCache) {
        emit(const ProfileLoading());
      }
      
      // Initialize default values
      var userProfile = Map<String, dynamic>.from(UserData.currentUser);
      var skills = List<String>.from(UserData.currentUser['skills'] ?? []);
      var education = <Map<String, dynamic>>[];
      var experience = <Map<String, dynamic>>[];
      var jobPreferences = <String, dynamic>{
        'preferredJobTypes': UserData.currentUser['preferredJobTypes'] ?? [],
        'preferredLocation': UserData.currentUser['preferredLocation'] ?? '',
        'expectedSalary': UserData.currentUser['expectedSalary'] ?? '',
      };
      var certificates = <Map<String, dynamic>>[];
      
      String? profileImagePath = userProfile['profileImage'] as String?;
      String? profileImageName;
      String? resumeFileName = userProfile['resume_file_name'] as String?;
      String? lastResumeUpdatedDate =
          userProfile['resume_last_updated'] as String?;
      String? resumeDownloadUrl;
      final resumeFileSizeRaw = userProfile['resume_file_size'];
      var resumeFileSize = 0;
      if (resumeFileSizeRaw is num) {
        resumeFileSize = resumeFileSizeRaw.toInt();
      } else if (resumeFileSizeRaw is String) {
        final parsedSize = int.tryParse(resumeFileSizeRaw);
        if (parsedSize != null) {
          resumeFileSize = parsedSize;
        }
      }
      var loadedFromApi = false;

      try {
        debugPrint('🔵 [ProfileBloc] Calling getStudentProfile API...');
        final studentProfileResponse = await _apiService.getStudentProfile();
        final profiles = studentProfileResponse.data.profiles;

        if (profiles.isNotEmpty) {
          final StudentProfile profile = profiles.first;

          debugPrint(
            '🔵 [ProfileBloc] Profile fetched for user_id: ${profile.userId}',
          );

          // Skills are now a List<String>
          skills = profile.professionalInfo.skills;

          // Parse experience - new structure
          experience = profile.professionalInfo.experience
              .map(
                (exp) => {
                  'company': exp.companyName,
                  'position': exp.position,
                  'startDate': exp.startDate,
                  'endDate': exp.endDate.isEmpty ? 'Present' : exp.endDate,
                  'companyLocation': exp.companyLocation ?? '',
                  'description': exp.description ?? '',
                },
              )
              .toList();

          // Parse education - new structure
          education = profile.professionalInfo.education
              .map(
                (edu) => {
                  'qualification': edu.qualification,
                  'institute': edu.institute,
                  'startYear': edu.startYear,
                  'endYear': edu.endYear,
                  'isPursuing': edu.isPursuing,
                  'pursuingYear': edu.pursuingYear,
                  'cgpa': edu.cgpa,
                },
              )
              .toList();

          // Parse projects
          final parsedProjects = profile.professionalInfo.projects
              .map((project) => {'name': project.name, 'link': project.link})
              .where(
                (project) =>
                    (project['name'] as String).isNotEmpty ||
                    (project['link'] as String).isNotEmpty,
              )
              .toList();

          // Parse social links - NEW STRUCTURE: Array of objects with title and profile_url
          // Backend sends: [{"title": "Portfolio", "profile_url": "https://..."}, ...]
          final socialLinksList = profile.socialLinks;
          debugPrint(
            '🟢 [ProfileBloc] Parsed ${socialLinksList.length} social links from API',
          );

          // Also extract individual links for backward compatibility with UI
          // NOTE: These individual fields are for UI display only, not for API payload
          String? portfolioLink;
          String? linkedinUrl;
          String? githubUrl;
          String? twitterUrl;

          for (final link in socialLinksList) {
            final title = link.title.toLowerCase();
            if (title.contains('portfolio')) {
              portfolioLink = link.profileUrl;
            } else if (title.contains('linkedin')) {
              linkedinUrl = link.profileUrl;
            } else if (title.contains('github')) {
              githubUrl = link.profileUrl;
            } else if (title.contains('twitter')) {
              twitterUrl = link.profileUrl;
            }
          }

          final jobType = profile.professionalInfo.jobType;
          final normalizedJobTypes = jobType.isNotEmpty
              ? <String>[jobType]
              : <String>[];

          final resumePath = profile.documents.resume;
          resumeFileName = resumePath.isNotEmpty
              ? resumePath.split('/').last
              : null;
          lastResumeUpdatedDate = null; // API doesn't provide this
          resumeFileSize = 0;
          resumeDownloadUrl = resumePath.isNotEmpty ? resumePath : null;

          certificates = [];

          final certificatePath = profile.documents.certificates;
          if (certificatePath.isNotEmpty) {
            final certificateName = certificatePath.split('/').last;
            certificates.add({
              'name': certificateName,
              'type': 'Certificate',
              'uploadDate': '',
              'size': 0,
              'extension': certificateName.split('.').last,
              'path': certificatePath,
            });
          }

          // Contact info
          final contactEmail = profile.contactInfo?.contactEmail ?? '';
          final contactPhone = profile.contactInfo?.contactPhone ?? '';

          userProfile = {
            'id': profile.userId.toString(),
            'name': profile.personalInfo.userName,
            'email': profile.personalInfo.email,
            'phone': profile.personalInfo.phoneNumber,
            'contactEmail': contactEmail,
            'contactPhone': contactPhone,
            'location': profile.personalInfo.location,
            'gender': profile.personalInfo.gender,
            'dateOfBirth': profile.personalInfo.dateOfBirth,
            'bio': profile.additionalInfo.bio,
            'profileImage': null,
            'portfolioLink': portfolioLink ?? '',
            'linkedinUrl': linkedinUrl ?? '',
            'githubUrl': githubUrl ?? '',
            'twitterUrl': twitterUrl ?? '',
            'aadharNumber': profile.documents.aadharNumber,
            'languages': profile.professionalInfo.languages,
            'jobType': profile.professionalInfo.jobType,
            'trade': profile.professionalInfo.trade,
            'latitude': profile.personalInfo.latitude,
            'longitude': profile.personalInfo.longitude,
            'projects': parsedProjects,
            'socialLinks': socialLinksList
                .map((l) => {'title': l.title, 'profile_url': l.profileUrl})
                .toList(),
          };

          jobPreferences = {
            'preferredJobTypes': normalizedJobTypes,
            'preferredLocation': profile.personalInfo.location,
            'expectedSalary': 'Not specified',
          };
          profileImagePath = null;
          profileImageName = null;

          debugPrint(
            '✅ [ProfileBloc] Profile data loaded successfully from API',
          );
          debugPrint('🔵 [ProfileBloc] Skills count: ${skills.length}');
          debugPrint('🔵 [ProfileBloc] Experience count: ${experience.length}');
          loadedFromApi = true;
          
          // Store in cache after successful API load
          await _cacheService.storeProfileData(
            userProfile: userProfile,
            skills: skills,
            education: education,
            experience: experience,
            jobPreferences: jobPreferences,
            certificates: certificates,
            profileImagePath: profileImagePath,
            profileImageName: profileImageName,
            resumeFileName: resumeFileName,
            lastResumeUpdatedDate: lastResumeUpdatedDate,
            resumeFileSize: resumeFileSize,
            resumeDownloadUrl: resumeDownloadUrl,
          );
          debugPrint('✅ [ProfileBloc] Profile data cached successfully');
        } else {
          debugPrint('⚠️ [ProfileBloc] API returned an empty profile list');
        }
      } catch (e, stackTrace) {
        debugPrint('🔴 [ProfileBloc] API call failed, using fallback data');
        debugPrint('🔴 [ProfileBloc] Error: $e');
        debugPrint('🔴 [ProfileBloc] StackTrace: $stackTrace');
      }

      final sectionExpansionStates = {
        'profile': false,
        'summary': false,
        'education': false,
        'skills': false,
        'experience': false,
        'resume': false,
        'certificates': false,
        'contact': false,
        'general_info': false,
        'social': false,
      };

      if (!loadedFromApi) {
        debugPrint('⚠️ [ProfileBloc] Loading mock/dummy data as fallback');
      }

      userProfile.putIfAbsent('latitude', () => 0.0);
      userProfile.putIfAbsent('longitude', () => 0.0);
      userProfile.putIfAbsent('projects', () => <Map<String, dynamic>>[]);

      // Store in cache if loaded from API (even if it failed, store what we have)
      if (loadedFromApi || event.forceRefresh) {
        await _cacheService.storeProfileData(
          userProfile: userProfile,
          skills: skills,
          education: education,
          experience: experience,
          jobPreferences: jobPreferences,
          certificates: certificates,
          profileImagePath: profileImagePath,
          profileImageName: profileImageName,
          resumeFileName: resumeFileName,
          lastResumeUpdatedDate: lastResumeUpdatedDate,
          resumeFileSize: resumeFileSize,
          resumeDownloadUrl: resumeDownloadUrl,
        );
      }

      // Only emit if we're not using cached data (already emitted above)
      if (!useCache || event.forceRefresh) {
        emit(
          ProfileDetailsLoaded(
            userProfile: userProfile,
            skills: skills,
            education: education,
            experience: experience,
            jobPreferences: jobPreferences,
            sectionExpansionStates: sectionExpansionStates,
            certificates: certificates,
            profileImagePath: profileImagePath,
            profileImageName: profileImageName,
            resumeFileName: resumeFileName,
            lastResumeUpdatedDate: lastResumeUpdatedDate,
            resumeFileSize: resumeFileSize,
            resumeDownloadUrl: resumeDownloadUrl,
            isSyncing: false,
            statusMessage: null,
            statusIsError: false,
            statusMessageKey: 0,
          ),
        );
      }
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to load profile');
    }
  }

  /// Handle update profile
  Future<void> _onUpdateProfile(
    UpdateProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.currentUser = updatedProfile; // This is const, so we can't modify it

      emit(ProfileUpdateSuccess(message: 'Profile updated successfully'));
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to update profile');
    }
  }

  /// Handle update profile image
  Future<void> _onUpdateProfileImage(
    UpdateProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.currentUser = updatedProfile; // This is const, so we can't modify it

      emit(ProfileImageUpdateSuccess(imagePath: event.imagePath));
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to update profile image');
    }
  }

  /// Handle update job preferences
  Future<void> _onUpdateJobPreferences(
    UpdateJobPreferencesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update mock data (Note: In real app, this would be an API call)
      // UserData.jobPreferences = updatedPreferences; // This is const, so we can't modify it

      emit(
        JobPreferencesUpdateSuccess(
          message: 'Job preferences updated successfully',
        ),
      );
    } catch (e) {
      emit(
        ProfileError(
          message: 'Failed to update job preferences: ${e.toString()}',
        ),
      );
    }
  }

  /// Handle update skills
  Future<void> _onUpdateSkills(
    UpdateSkillsEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Update skills (Note: In real app, this would be an API call)
      // UserData.userSkills = event.skills; // This is const, so we can't modify it

      emit(SkillsUpdateSuccess(skills: event.skills)      );
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to update skills');
    }
  }

  /// Handle update education
  Future<void> _onUpdateEducation(
    UpdateEducationEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Add education (Note: In real app, this would be an API call)
      // UserData.userEducation.add(newEducation); // This is const, so we can't modify it

      emit(EducationUpdateSuccess(message: 'Education updated successfully')      );
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to update education');
    }
  }

  /// Handle update experience
  Future<void> _onUpdateExperience(
    UpdateExperienceEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Add experience (Note: In real app, this would be an API call)
      // UserData.userExperience.add(newExperience); // This is const, so we can't modify it

      emit(ExperienceUpdateSuccess(message: 'Experience updated successfully')      );
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to update experience');
    }
  }

  /// Handle delete experience
  Future<void> _onDeleteExperience(
    DeleteExperienceEvent event,
    Emitter<ProfileState> emit,
  ) async {
    try {
      emit(const ProfileLoading());

      // Simulate API call delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Delete experience (Note: In real app, this would be an API call)
      // if (event.index >= 0 && event.index < UserData.userExperience.length) {
      //   UserData.userExperience.removeAt(event.index);
      // }

      emit(ExperienceUpdateSuccess(message: 'Experience deleted successfully')      );
    } catch (e) {
      _handleError(e, emit, defaultMessage: 'Failed to delete experience');
    }
  }

  /// Handle refresh profile data (force reload from API)
  Future<void> _onRefreshProfileData(
    RefreshProfileDataEvent event,
    Emitter<ProfileState> emit,
  ) async {
    // Force refresh - clear cache and reload from API
    await _cacheService.clearCache();
    add(const LoadProfileDataEvent(forceRefresh: true));
  }

  /// Handle toggle section expand/collapse
  void _onToggleSection(ToggleSectionEvent event, Emitter<ProfileState> emit) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      final updatedExpansionStates = Map<String, bool>.from(
        currentState.sectionExpansionStates,
      );
      updatedExpansionStates[event.section] =
          !(updatedExpansionStates[event.section] ?? false);

      emit(
        currentState.copyWith(sectionExpansionStates: updatedExpansionStates),
      );
    }
  }

  Future<void> _onInlineProfileHeaderUpdate(
    UpdateProfileHeaderInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedProfile = Map<String, dynamic>.from(currentState.userProfile);

    updatedProfile['name'] = event.name;
    updatedProfile['email'] = event.email;
    updatedProfile['phone'] = event.phone;
    updatedProfile['location'] = event.location;
    updatedProfile['bio'] = event.bio;

    await _applyLocationCoordinates(updatedProfile);

    final updatedState = currentState.copyWith(userProfile: updatedProfile);
    await _syncProfileWithServer(updatedState, emit, source: 'profile_header');
  }

  Future<void> _onInlineResumeUpdate(
    UpdateProfileResumeInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      final sanitizedName = event.fileName.trim();
      final sanitizedDate = event.lastUpdated?.trim() ?? '';
      final sanitizedUrl = event.downloadUrl?.trim() ?? '';

      final updatedCertificates =
          List<Map<String, dynamic>>.from(currentState.certificates)
            ..removeWhere(
              (cert) =>
                  (cert['type'] ?? '').toString().toLowerCase() == 'resume',
            );

      final updatedState = currentState.copyWith(
        resumeFileName: sanitizedName.isNotEmpty ? sanitizedName : null,
        lastResumeUpdatedDate: sanitizedDate.isNotEmpty
            ? sanitizedDate
            : null,
        resumeDownloadUrl: sanitizedUrl.isNotEmpty ? sanitizedUrl : null,
        certificates: updatedCertificates,
      );
      
      emit(updatedState);
      
      // Update cache
      await _updateCacheFromState(updatedState);
    }
  }

  Future<void> _onInlineContactUpdate(
    UpdateProfileContactInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedProfile = Map<String, dynamic>.from(currentState.userProfile);

    updatedProfile['email'] = event.email;
    updatedProfile['phone'] = event.phone;
    updatedProfile['location'] = event.location;

    final gender = event.gender?.trim() ?? '';
    updatedProfile['gender'] = gender.isNotEmpty ? gender : null;

    final dob = event.dateOfBirth?.trim() ?? '';
    updatedProfile['dateOfBirth'] = dob.isNotEmpty ? dob : null;

    // Update contact_info fields
    final contactEmail = event.contactEmail?.trim() ?? '';
    updatedProfile['contactEmail'] = contactEmail.isNotEmpty
        ? contactEmail
        : null;

    final contactPhone = event.contactPhone?.trim() ?? '';
    updatedProfile['contactPhone'] = contactPhone.isNotEmpty
        ? contactPhone
        : null;

    await _applyLocationCoordinates(updatedProfile);

    final updatedState = currentState.copyWith(userProfile: updatedProfile);
    await _syncProfileWithServer(updatedState, emit, source: 'contact');
  }

  Future<void> _onInlineGeneralInfoUpdate(
    UpdateProfileGeneralInfoInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      debugPrint(
        '⚠️ [ProfileBloc] _onInlineGeneralInfoUpdate: State is not ProfileDetailsLoaded',
      );
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedProfile = Map<String, dynamic>.from(currentState.userProfile);

    // Update gender
    final gender = event.gender?.trim() ?? '';
    updatedProfile['gender'] = gender.isNotEmpty ? gender : null;

    // Update date of birth
    final dob = event.dateOfBirth?.trim() ?? '';
    updatedProfile['dateOfBirth'] = dob.isNotEmpty ? dob : null;

    // Update languages - already a List<String> from event
    updatedProfile['languages'] = List<String>.from(event.languages);

    // Update aadhar number
    final aadhar = event.aadharNumber?.trim() ?? '';
    updatedProfile['aadharNumber'] = aadhar.isNotEmpty ? aadhar : null;

    debugPrint('🟢 [ProfileBloc] _onInlineGeneralInfoUpdate: Updating profile');
    debugPrint('   Gender: ${updatedProfile['gender']}');
    debugPrint('   DateOfBirth: ${updatedProfile['dateOfBirth']}');
    debugPrint('   Languages: ${updatedProfile['languages']}');
    debugPrint('   AadharNumber: ${updatedProfile['aadharNumber']}');

    final updatedState = currentState.copyWith(userProfile: updatedProfile);
    await _syncProfileWithServer(updatedState, emit, source: 'general_info');
  }

  Future<void> _onInlineSocialLinksUpdate(
    UpdateProfileSocialLinksInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedProfile = Map<String, dynamic>.from(currentState.userProfile);

    // Update social links array
    updatedProfile['socialLinks'] = event.socialLinks;

    // Also update individual fields for backward compatibility with UI
    String? portfolioLink;
    String? linkedinUrl;
    String? githubUrl;
    String? twitterUrl;

    for (final link in event.socialLinks) {
      final title = (link['title']?.toString() ?? '').toLowerCase();
      final url = link['profile_url']?.toString() ?? '';
      if (title.contains('portfolio')) {
        portfolioLink = url;
      } else if (title.contains('linkedin')) {
        linkedinUrl = url;
      } else if (title.contains('github')) {
        githubUrl = url;
      } else if (title.contains('twitter')) {
        twitterUrl = url;
      }
    }

    updatedProfile['portfolioLink'] = portfolioLink;
    updatedProfile['linkedinUrl'] = linkedinUrl;
    updatedProfile['githubUrl'] = githubUrl;
    updatedProfile['twitterUrl'] = twitterUrl;

    final updatedState = currentState.copyWith(userProfile: updatedProfile);
    await _syncProfileWithServer(updatedState, emit, source: 'social_links');
  }

  void _onInlineCertificatesUpdate(
    UpdateProfileCertificatesInlineEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      emit(currentState.copyWith(certificates: event.certificates));
    }
  }

  Future<void> _onInlineSkillsUpdate(
    UpdateProfileSkillsInlineEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedState = currentState.copyWith(skills: event.skills);

    await _syncProfileWithServer(updatedState, emit, source: 'skills');
  }

  Future<void> _onInlineExperienceUpdate(
    UpdateProfileExperienceListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedState = currentState.copyWith(experience: event.experience);

    await _syncProfileWithServer(updatedState, emit, source: 'experience');
  }

  Future<void> _onInlineEducationUpdate(
    UpdateProfileEducationListEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileDetailsLoaded) {
      return;
    }
    final currentState = state as ProfileDetailsLoaded;
    final updatedState = currentState.copyWith(education: event.education);

    await _syncProfileWithServer(updatedState, emit, source: 'education');
  }

  Future<void> _applyLocationCoordinates(Map<String, dynamic> profile) async {
    double? latitude = _parseDouble(profile['latitude']);
    double? longitude = _parseDouble(profile['longitude']);

    if (latitude != null && longitude != null) {
      profile['latitude'] = latitude;
      profile['longitude'] = longitude;
      if (latitude != 0.0 || longitude != 0.0) {
        return;
      }
    }

    try {
      await _locationService.initialize();
      final savedLocation = await _locationService.getSavedLocation();
      if (savedLocation != null) {
        profile['latitude'] = savedLocation.latitude;
        profile['longitude'] = savedLocation.longitude;
        return;
      }
    } catch (e) {
      debugPrint('⚠️ [ProfileBloc] Unable to fetch saved location: $e');
    }

    profile['latitude'] = latitude ?? 0.0;
    profile['longitude'] = longitude ?? 0.0;
  }

  Future<void> _syncProfileWithServer(
    ProfileDetailsLoaded pendingState,
    Emitter<ProfileState> emit, {
    String? source,
  }) async {
    debugPrint(
      '🔵 [ProfileBloc] Syncing profile${source != null ? ' ($source)' : ''}',
    );

    emit(pendingState.copyWith(isSyncing: true, statusMessage: null));

    try {
      final payload = await _buildProfileUpdatePayload(pendingState);
      final response = await _apiService.updateStudentProfile(payload);
      final message = response.message.isNotEmpty
          ? response.message
          : 'Student profile updated successfully';

      final updatedState = pendingState.copyWith(
        isSyncing: false,
        statusMessage: message,
        statusIsError: !response.isSuccessful,
        statusMessageKey: _nextStatusKey(),
      );

      emit(updatedState);

      // Update cache after successful sync
      if (response.isSuccessful) {
        await _updateCacheFromState(updatedState);
        debugPrint('✅ [ProfileBloc] Cache updated after profile sync');
      }
    } catch (e) {
      final errorMessage =
          'Failed to update profile: ${_formatErrorMessage(e)}';
      debugPrint('🔴 [ProfileBloc] $errorMessage');
      emit(
        pendingState.copyWith(
          isSyncing: false,
          statusMessage: errorMessage,
          statusIsError: true,
          statusMessageKey: _nextStatusKey(),
        ),
      );
    }
  }

  /// Helper method to update cache from current state
  Future<void> _updateCacheFromState(ProfileDetailsLoaded state) async {
    try {
      await _cacheService.storeProfileData(
        userProfile: state.userProfile,
        skills: state.skills,
        education: state.education,
        experience: state.experience,
        jobPreferences: state.jobPreferences,
        certificates: state.certificates,
        profileImagePath: state.profileImagePath,
        profileImageName: state.profileImageName,
        resumeFileName: state.resumeFileName,
        lastResumeUpdatedDate: state.lastResumeUpdatedDate,
        resumeFileSize: state.resumeFileSize,
        resumeDownloadUrl: state.resumeDownloadUrl,
      );
    } catch (e) {
      debugPrint('⚠️ [ProfileBloc] Failed to update cache: $e');
    }
  }

  Future<Map<String, dynamic>> _buildProfileUpdatePayload(
    ProfileDetailsLoaded state,
  ) async {
    final userProfile = Map<String, dynamic>.from(state.userProfile);
    final userId = await _resolveUserId(userProfile);

    if (userId == null) {
      throw Exception('Unable to determine user ID for profile update');
    }

    double latitude = _parseDouble(userProfile['latitude']) ?? 0.0;
    double longitude = _parseDouble(userProfile['longitude']) ?? 0.0;

    if (latitude == 0.0 && longitude == 0.0) {
      try {
        await _locationService.initialize();
        final savedLocation = await _locationService.getSavedLocation();
        if (savedLocation != null) {
          latitude = savedLocation.latitude;
          longitude = savedLocation.longitude;
        }
      } catch (e) {
        debugPrint('⚠️ [ProfileBloc] Unable to load saved location: $e');
      }
    }

    // Build personal_info - backend accepts both flat and nested structure
    // Backend expects: dob OR date_of_birth in personal_info
    final dobValue = _normalizeDate(userProfile['dateOfBirth']);
    final genderValue = (userProfile['gender']?.toString() ?? '').trim().toLowerCase();
    final locationValue = (userProfile['location']?.toString() ?? '').trim();
    
    final personalInfo = <String, dynamic>{
      'email': userProfile['email']?.toString() ?? '',
      'user_name': userProfile['name']?.toString() ?? '',
      'phone_number': userProfile['phone']?.toString() ?? '',
    };
    
    // Add optional fields only if they have values (backend only updates non-null fields)
    if (dobValue.isNotEmpty) {
      personalInfo['dob'] = dobValue; // Backend checks for 'dob' first
      personalInfo['date_of_birth'] = dobValue; // Also send date_of_birth for compatibility
    }
    
    if (genderValue.isNotEmpty) {
      personalInfo['gender'] = genderValue;
    }
    
    // Always include location (even if empty) so backend can clear it when user empties the field
    personalInfo['location'] = locationValue;
    
    // Always include latitude/longitude (can be 0.0)
    personalInfo['latitude'] = latitude;
    personalInfo['longitude'] = longitude;

    // Skills - already a List<String>
    final skills = state.skills
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toList();

    // Education - new structure as array
    // Handle end_year: if is_pursuing is true, end_year should be empty string
    final educationPayload = state.education.map((edu) {
      final isPursuing =
          edu['isPursuing'] == true ||
          edu['isPursuing'] == 1 ||
          edu['isPursuing'] == '1' ||
          edu['isPursuing'] == 'true';
      final endYear = isPursuing ? '' : (edu['endYear']?.toString() ?? '');

      return {
        'qualification': edu['qualification']?.toString() ?? '',
        'institute': edu['institute']?.toString() ?? '',
        'start_year': edu['startYear']?.toString() ?? '',
        'end_year': endYear,
        'is_pursuing': isPursuing,
        'pursuing_year': edu['pursuingYear'],
        'cgpa': edu['cgpa'],
      };
    }).toList();

    // Experience - new structure as array
    // Handle endDate: if it's "Present", send empty string
    final experiencePayload = state.experience
        .map(
          (exp) => {
            'company_name': exp['company']?.toString() ?? '',
            'position': exp['position']?.toString() ?? '',
            'start_date': exp['startDate']?.toString() ?? '',
            'end_date':
                (exp['endDate']?.toString() ?? '').toLowerCase() == 'present'
                ? ''
                : (exp['endDate']?.toString() ?? ''),
            'company_location': exp['companyLocation']?.toString() ?? '',
            'description': exp['description']?.toString() ?? '',
          },
        )
        .toList();

    // Projects
    final projectsPayload = _normalizeProjects(userProfile['projects']);

    // Languages - should be List<String>
    final languages = _normalizeStringList(userProfile['languages']);

    // Documents - handle certificates as string (backend expects string, not array)
    final documents = _buildDocumentsPayload(userProfile, state);

    // Social Links - NEW STRUCTURE: Array of objects with title and profile_url
    // Backend expects: [{"title": "Portfolio", "profile_url": "https://..."}, ...]
    // Old structure (portfolio_link, linkedin_url) is no longer supported
    final socialLinksPayload = <Map<String, dynamic>>[];

    // Priority: Use socialLinks array if it exists (from backend - new structure)
    if (userProfile['socialLinks'] is List) {
      final existingLinks = userProfile['socialLinks'] as List;
      for (final link in existingLinks) {
        if (link is Map<String, dynamic>) {
          final title = link['title']?.toString() ?? '';
          final url = link['profile_url']?.toString() ?? '';
          if (title.isNotEmpty && url.isNotEmpty) {
            socialLinksPayload.add({'title': title, 'profile_url': url});
          }
        }
      }
      debugPrint(
        '🟢 [ProfileBloc] Building social_links payload: ${socialLinksPayload.length} links',
      );
    } else {
      // Fallback: Build from individual link fields (for backward compatibility during migration)
      // NOTE: This fallback can be removed once all data is migrated to new structure
      debugPrint(
        '⚠️ [ProfileBloc] Using fallback for social_links (old structure detected)',
      );
      final portfolioLink = userProfile['portfolioLink']?.toString() ?? '';
      if (portfolioLink.isNotEmpty) {
        socialLinksPayload.add({
          'title': 'Portfolio',
          'profile_url': portfolioLink,
        });
      }

      final linkedinUrl = userProfile['linkedinUrl']?.toString() ?? '';
      if (linkedinUrl.isNotEmpty) {
        socialLinksPayload.add({
          'title': 'LinkedIn',
          'profile_url': linkedinUrl,
        });
      }

      final githubUrl = userProfile['githubUrl']?.toString() ?? '';
      if (githubUrl.isNotEmpty) {
        socialLinksPayload.add({'title': 'GitHub', 'profile_url': githubUrl});
      }

      final twitterUrl = userProfile['twitterUrl']?.toString() ?? '';
      if (twitterUrl.isNotEmpty) {
        socialLinksPayload.add({'title': 'Twitter', 'profile_url': twitterUrl});
      }
    }

    // Always send an array (even if empty) to match backend structure
    debugPrint(
      '🔵 [ProfileBloc] Final social_links payload: ${jsonEncode(socialLinksPayload)}',
    );

    // Professional Info - only include fields with values
    final professionalInfo = <String, dynamic>{
      'skills': skills,
      'education': educationPayload,
      'experience': experiencePayload,
    };
    
    // Add optional fields only if they have values
    if (projectsPayload.isNotEmpty) {
      professionalInfo['projects'] = projectsPayload;
    }
    
    final jobTypeValue = (userProfile['jobType']?.toString() ?? '').trim();
    if (jobTypeValue.isNotEmpty) {
      professionalInfo['job_type'] = jobTypeValue;
    }
    
    final tradeValue = (userProfile['trade']?.toString() ?? '').trim();
    if (tradeValue.isNotEmpty) {
      professionalInfo['trade'] = tradeValue;
    }
    
    if (languages.isNotEmpty) {
      professionalInfo['languages'] = languages;
    }

    // Build payload - match backend structure exactly
    // Backend only updates fields that are provided (not null)
    final payload = <String, dynamic>{
      'personal_info': personalInfo,
      'professional_info': professionalInfo,
    };
    
    // Add documents only if it has any values
    if (documents.isNotEmpty) {
      payload['documents'] = documents;
    }
    
    // Always send social_links (even if empty array) - backend handles empty arrays
    payload['social_links'] = socialLinksPayload;
    
    // Add additional_info only if bio has value
    final bioValue = (userProfile['bio']?.toString() ?? '').trim();
    if (bioValue.isNotEmpty) {
      payload['additional_info'] = {'bio': bioValue};
    }

    // Add contact_info if either field has a value
    final contactEmailValue = (userProfile['contactEmail']?.toString() ?? '').trim();
    final contactPhoneValue = (userProfile['contactPhone']?.toString() ?? '').trim();
    if (contactEmailValue.isNotEmpty || contactPhoneValue.isNotEmpty) {
      final contactInfoPayload = <String, dynamic>{};
      if (contactEmailValue.isNotEmpty) {
        contactInfoPayload['contact_email'] = contactEmailValue;
      }
      if (contactPhoneValue.isNotEmpty) {
        contactInfoPayload['contact_phone'] = contactPhoneValue;
      }
      payload['contact_info'] = contactInfoPayload;
    }

    debugPrint('🔵 [ProfileBloc] Final payload structure:');
    debugPrint('   personal_info keys: ${personalInfo.keys.toList()}');
    debugPrint('   professional_info keys: ${professionalInfo.keys.toList()}');
    debugPrint('   documents keys: ${documents.keys.toList()}');
    debugPrint('   social_links count: ${socialLinksPayload.length}');

    return payload;
  }

  Map<String, dynamic> _buildDocumentsPayload(
    Map<String, dynamic> userProfile,
    ProfileDetailsLoaded state,
  ) {
    // Backend expects certificates as a string (comma-separated or single value)
    // If multiple certificates, join them; otherwise use the first one or empty string
    String certificatesValue = '';
    if (state.certificates.isNotEmpty) {
      final certificatePaths = state.certificates
          .map(
            (certificate) =>
                certificate['path']?.toString() ??
                certificate['name']?.toString(),
          )
          .whereType<String>()
          .where((value) => value.trim().isNotEmpty)
          .toList();

      // Join multiple certificates with comma, or use first one
      certificatesValue = certificatePaths.isNotEmpty
          ? certificatePaths.join(', ')
          : '';
    }

    final documents = <String, dynamic>{};
    
    // Add resume only if available
    final resumeValue = state.resumeDownloadUrl?.toString() ?? '';
    if (resumeValue.isNotEmpty) {
      documents['resume'] = resumeValue;
    }
    
    // Add certificates only if available
    if (certificatesValue.isNotEmpty) {
      documents['certificates'] = certificatesValue;
    }
    
    // Add aadhar_number only if available (backend checks both flat and nested)
    final aadharValue = (userProfile['aadharNumber']?.toString() ?? '').trim();
    if (aadharValue.isNotEmpty) {
      documents['aadhar_number'] = aadharValue;
    }
    
    return documents;
  }

  Future<int?> _resolveUserId(Map<String, dynamic> userProfile) async {
    final storedId = await _tokenStorage.getUserId();
    final parsedStoredId = _parseInt(storedId);
    if (parsedStoredId != null) {
      return parsedStoredId;
    }

    final token = await _tokenStorage.getToken();
    if (token != null && token.isNotEmpty) {
      final decodedToken = _decodeJwt(token);
      final tokenUserId = decodedToken?['user_id'] ?? decodedToken?['id'];
      final parsedTokenId = _parseInt(tokenUserId);
      if (parsedTokenId != null) {
        return parsedTokenId;
      }
    }

    final profileId = userProfile['userId'] ?? userProfile['id'];
    return _parseInt(profileId);
  }

  Map<String, dynamic>? _decodeJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        return null;
      }
      final normalized = base64Url.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      final decoded = jsonDecode(payload);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (e) {
      debugPrint('⚠️ [ProfileBloc] Failed to decode JWT: $e');
    }
    return null;
  }

  List<Map<String, dynamic>> _normalizeProjects(dynamic projects) {
    if (projects is List) {
      return projects
          .map((project) {
            if (project is Map) {
              final name = project['name']?.toString() ?? '';
              final link = project['link']?.toString() ?? '';
              if (name.trim().isEmpty && link.trim().isEmpty) {
                return null;
              }
              return {'name': name, 'link': link};
            }
            return null;
          })
          .whereType<Map<String, dynamic>>()
          .toList();
    }
    return <Map<String, dynamic>>[];
  }

  List<String> _normalizeStringList(dynamic value) {
    if (value is List) {
      return value
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    if (value is String) {
      if (value.trim().isEmpty) {
        return <String>[];
      }
      return value
          .split(RegExp(r'[,\n]+'))
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return <String>[];
  }

  double? _parseDouble(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString());
  }

  int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    final sanitized = value.toString().replaceAll(RegExp(r'[^0-9-]'), '');
    return sanitized.isEmpty ? null : int.tryParse(sanitized);
  }

  int _nextStatusKey() {
    _statusMessageCounter += 1;
    return _statusMessageCounter;
  }

  String _normalizeDate(dynamic value) {
    final raw = value?.toString().trim() ?? '';
    if (raw.isEmpty) {
      return '';
    }

    final isoPattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (isoPattern.hasMatch(raw)) {
      return raw;
    }

    final slashPattern = RegExp(r'^(\d{2})/(\d{2})/(\d{4})$');
    final dashPattern = RegExp(r'^(\d{2})-(\d{2})-(\d{4})$');
    RegExpMatch? match =
        slashPattern.firstMatch(raw) ?? dashPattern.firstMatch(raw);
    if (match != null) {
      final day = match.group(1);
      final month = match.group(2);
      final year = match.group(3);
      if (day != null && month != null && year != null) {
        return '$year-${month.padLeft(2, '0')}-${day.padLeft(2, '0')}';
      }
    }

    try {
      final parsed = DateTime.parse(raw);
      return '${parsed.year.toString().padLeft(4, '0')}-'
          '${parsed.month.toString().padLeft(2, '0')}-'
          '${parsed.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return raw;
    }
  }

  String _formatErrorMessage(Object error) {
    if (error is Exception) {
    final message = error.toString();
      if (message.startsWith('Exception: ')) {
        final extracted = message.substring('Exception: '.length);
        return extracted.isEmpty ? 'An unexpected error occurred' : extracted;
      }
      return message.isEmpty ? 'An unexpected error occurred' : message;
    }
    
    final message = error.toString();
    if (message.isEmpty || message == 'null') {
      return 'An unexpected error occurred';
    }
    
    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  /// Handle delete certificate
  void _onDeleteCertificate(
    DeleteCertificateEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;
      final updatedCertificates = List<Map<String, dynamic>>.from(
        currentState.certificates,
      );
      updatedCertificates.remove(event.certificate);

      emit(currentState.copyWith(certificates: updatedCertificates));

      // Emit success state
      emit(
        const CertificateDeletedSuccess(
          message: 'Certificate deleted successfully!',
        ),
      );
    }
  }

  /// Handle remove profile image
  void _onRemoveProfileImage(
    RemoveProfileImageEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileDetailsLoaded) {
      final currentState = state as ProfileDetailsLoaded;

      emit(
        currentState.copyWith(profileImagePath: null, profileImageName: null),
      );

      // Emit success state
      emit(const ProfileImageRemovedSuccess());
    }
  }

  /// Handle update job type
  void _onUpdateJobType(UpdateJobTypeEvent event, Emitter<ProfileState> emit) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(currentState.copyWith(selectedJobType: event.jobType));
    } else {
      emit(ProfileBuilderState(selectedJobType: event.jobType));
    }
  }

  /// Handle update experience level
  void _onUpdateExperienceLevel(
    UpdateExperienceLevelEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(
        currentState.copyWith(selectedExperienceLevel: event.experienceLevel),
      );
    } else {
      emit(ProfileBuilderState(selectedExperienceLevel: event.experienceLevel));
    }
  }

  /// Handle update preferred location
  void _onUpdatePreferredLocation(
    UpdatePreferredLocationEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileBuilderState) {
      final currentState = state as ProfileBuilderState;
      emit(
        currentState.copyWith(
          selectedPreferredLocation: event.preferredLocation,
        ),
      );
    } else {
      emit(
        ProfileBuilderState(selectedPreferredLocation: event.preferredLocation),
      );
    }
  }

  /// Handle update selected trade
  void _onUpdateSelectedTrade(
    UpdateSelectedTradeEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedTrade: event.trade));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedTrade: event.trade,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected state
  void _onUpdateSelectedState(
    UpdateSelectedStateEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedState: event.state));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedState: event.state,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected city
  void _onUpdateSelectedCity(
    UpdateSelectedCityEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedCity: event.city));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedCity: event.city,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update selected salary range
  void _onUpdateSelectedSalaryRange(
    UpdateSelectedSalaryRangeEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(selectedSalaryRange: event.salaryRange));
    } else {
      emit(
        PersonalizeJobfeedState(
          selectedSalaryRange: event.salaryRange,
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle update availability
  void _onUpdateAvailability(
    UpdateAvailabilityEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      emit(currentState.copyWith(availability: event.availability));
    } else {
      emit(
        PersonalizeJobfeedState(
          availability: event.availability,
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle toggle job sector
  void _onToggleJobSector(
    ToggleJobSectorEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSectors = List<String>.from(currentState.selectedSectors);

      if (event.isSelected) {
        if (!updatedSectors.contains(event.sector)) {
          updatedSectors.add(event.sector);
        }
      } else {
        updatedSectors.remove(event.sector);
      }

      emit(currentState.copyWith(selectedSectors: updatedSectors));
    } else {
      final sectors = event.isSelected ? <String>[event.sector] : <String>[];
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: sectors,
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle toggle job type
  void _onToggleJobType(ToggleJobTypeEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedJobTypes = List<String>.from(currentState.selectedJobTypes);

      if (event.isSelected) {
        if (!updatedJobTypes.contains(event.jobType)) {
          updatedJobTypes.add(event.jobType);
        }
      } else {
        updatedJobTypes.remove(event.jobType);
      }

      emit(currentState.copyWith(selectedJobTypes: updatedJobTypes));
    } else {
      final jobTypes = event.isSelected ? <String>[event.jobType] : <String>[];
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: jobTypes,
          skills: ['Wiring'],
        ),
      );
    }
  }

  /// Handle add skill
  void _onAddSkill(AddSkillEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSkills = List<String>.from(currentState.skills);
      if (!updatedSkills.contains(event.skill)) {
        updatedSkills.add(event.skill);
      }
      emit(currentState.copyWith(skills: updatedSkills));
    } else {
      emit(
        PersonalizeJobfeedState(
          availability: 'Immediately Available',
          selectedSectors: ['Power Plant'],
          selectedJobTypes: ['Full Time', 'Internship'],
          skills: [event.skill],
        ),
      );
    }
  }

  /// Handle remove skill
  void _onRemoveSkill(RemoveSkillEvent event, Emitter<ProfileState> emit) {
    if (state is PersonalizeJobfeedState) {
      final currentState = state as PersonalizeJobfeedState;
      final updatedSkills = List<String>.from(currentState.skills);
      updatedSkills.remove(event.skill);
      emit(currentState.copyWith(skills: updatedSkills));
    }
  }

  /// Handle update search query
  void _onUpdateSearchQuery(
    UpdateSearchQueryEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationState) {
      final currentState = state as LocationState;
      emit(currentState.copyWith(searchQuery: event.searchQuery));
    } else {
      // Initialize with default locations
      final locations = [
        {
          'name': 'Baker Street Library',
          'address': '221B Baker Street London, NW1 6XE United Kingdom',
        },
        {
          'name': 'The Greenfield Mall',
          'address':
              '45 High Street Greenfield, Manchester, M1 2AB United Kingdom',
        },
        {
          'name': 'Riverbank Business Park',
          'address': 'Unit 12, Riverside Drive Bristol, BS1 5RT United Kingdom',
        },
        {
          'name': 'Elmwood Community Centre',
          'address': '78 Elmwood Avenue Birmingham, B12 3DF United Kingdom',
        },
      ];
      emit(LocationState(searchQuery: event.searchQuery, locations: locations));
    }
  }

  /// Handle select location
  void _onSelectLocation(
    SelectLocationEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationState) {
      final currentState = state as LocationState;
      emit(currentState.copyWith(selectedLocation: event.locationName));
    } else {
      // Initialize with default locations
      final locations = [
        {
          'name': 'Baker Street Library',
          'address': '221B Baker Street London, NW1 6XE United Kingdom',
        },
        {
          'name': 'The Greenfield Mall',
          'address':
              '45 High Street Greenfield, Manchester, M1 2AB United Kingdom',
        },
        {
          'name': 'Riverbank Business Park',
          'address': 'Unit 12, Riverside Drive Bristol, BS1 5RT United Kingdom',
        },
        {
          'name': 'Elmwood Community Centre',
          'address': '78 Elmwood Avenue Birmingham, B12 3DF United Kingdom',
        },
      ];
      emit(
        LocationState(
          selectedLocation: event.locationName,
          searchQuery: '',
          locations: locations,
        ),
      );
    }
  }

  /// Handle request location permission
  void _onRequestLocationPermission(
    RequestLocationPermissionEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(currentState.copyWith(isProcessing: true));
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: true,
          permissionGranted: false,
          permissionDenied: false,
        ),
      );
    }
  }

  /// Handle location permission granted
  void _onLocationPermissionGranted(
    LocationPermissionGrantedEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(
        currentState.copyWith(
          isProcessing: false,
          permissionGranted: true,
          permissionDenied: false,
        ),
      );
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: false,
          permissionGranted: true,
          permissionDenied: false,
        ),
      );
    }
  }

  /// Handle location permission denied
  void _onLocationPermissionDenied(
    LocationPermissionDeniedEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is LocationPermissionState) {
      final currentState = state as LocationPermissionState;
      emit(
        currentState.copyWith(
          isProcessing: false,
          permissionGranted: false,
          permissionDenied: true,
        ),
      );
    } else {
      emit(
        const LocationPermissionState(
          isProcessing: false,
          permissionGranted: false,
          permissionDenied: true,
        ),
      );
    }
  }

  /// Handle change job status tab
  void _onChangeJobStatusTab(
    ChangeJobStatusTabEvent event,
    Emitter<ProfileState> emit,
  ) {
    emit(JobStatusTabState(selectedTabIndex: event.tabIndex));
  }

  /// Handle update profile edit form
  void _onUpdateProfileEditForm(
    UpdateProfileEditFormEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is ProfileEditFormState) {
      final currentState = state as ProfileEditFormState;
      emit(
        currentState.copyWith(
          name: event.name,
          email: event.email,
          phone: event.phone,
        ),
      );
    } else {
      emit(
        ProfileEditFormState(
          name: event.name,
          email: event.email,
          phone: event.phone,
        ),
      );
    }
  }

  /// Handle save profile changes
  Future<void> _onSaveProfileChanges(
    SaveProfileChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is ProfileEditFormState) {
      final currentState = state as ProfileEditFormState;
      emit(currentState.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(isSaving: false));
      emit(const ProfileChangesSavedState());
    }
  }

  /// Handle update skills list
  void _onUpdateSkillsList(
    UpdateSkillsListEvent event,
    Emitter<ProfileState> emit,
  ) {
    if (state is SkillsEditFormState) {
      final currentState = state as SkillsEditFormState;
      emit(currentState.copyWith(skills: event.skills));
    } else {
      emit(SkillsEditFormState(skills: event.skills));
    }
  }

  /// Handle save skills changes
  Future<void> _onSaveSkillsChanges(
    SaveSkillsChangesEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is SkillsEditFormState) {
      final currentState = state as SkillsEditFormState;
      emit(currentState.copyWith(isSaving: true));

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      emit(currentState.copyWith(isSaving: false));
      emit(const SkillsChangesSavedState());
    }
  }

  /// Helper method to handle errors and emit appropriate error state
  /// Detects network errors and formats messages accordingly
  void _handleError(dynamic error, Emitter<ProfileState> emit, {String? defaultMessage}) {
    final errorMessage = NetworkErrorHelper.isNetworkError(error)
        ? NetworkErrorHelper.getNetworkErrorMessage(error)
        : NetworkErrorHelper.extractErrorMessage(error, defaultMessage: defaultMessage);
    
    emit(ProfileError(message: errorMessage));
  }
}
