/// Profile Completion Service
/// Calculates profile completion percentage based on filled fields
class ProfileCompletionService {
  /// Calculate profile completion percentage
  /// Returns a value between 0.0 and 100.0
  /// Uses weighted average based on section importance
  static double calculateCompletionPercentage({
    required Map<String, dynamic> userProfile,
    required List<String> skills,
    required List<Map<String, dynamic>> education,
    required List<Map<String, dynamic>> experience,
    required List<Map<String, dynamic>> certificates,
    String? resumeFileName,
    String? profileImagePath,
  }) {
    // Calculate weighted percentage based on individual sections
    double weightedSum = 0.0;
    int totalWeight = 0;

    // 1. Profile Info (Weight: 15%) - Profile header fields: image, name, email, phone, location, bio
    int profileInfoCompleted = 0;
    int profileInfoTotal = 6;
    if (profileImagePath != null && profileImagePath.isNotEmpty) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['userName']) || _isNotEmpty(userProfile['name'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['email'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['phone'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['location'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['bio'])) profileInfoCompleted++;
    final profileInfoPercentage = profileInfoTotal > 0 
        ? (profileInfoCompleted / profileInfoTotal) * 100.0 
        : 0.0;
    weightedSum += profileInfoPercentage * 15;
    totalWeight += 15;

    // 2. General Info (Weight: 10%) - dateOfBirth, gender, languages, aadharNumber
    int generalInfoCompleted = 0;
    int generalInfoTotal = 4;
    if (_isNotEmpty(userProfile['dateOfBirth'])) generalInfoCompleted++;
    if (_isNotEmpty(userProfile['gender'])) generalInfoCompleted++;
    if (_isNotEmptyList(userProfile['languages'])) generalInfoCompleted++;
    if (_isNotEmpty(userProfile['aadharNumber'])) generalInfoCompleted++;
    final generalInfoPercentage = generalInfoTotal > 0 
        ? (generalInfoCompleted / generalInfoTotal) * 100.0 
        : 0.0;
    weightedSum += generalInfoPercentage * 10;
    totalWeight += 10;

    // 3. Skills and Expertise (Weight: 10%)
    int skillsCompleted = skills.isNotEmpty ? 1 : 0;
    int skillsTotal = 1;
    final skillsPercentage = skillsTotal > 0 
        ? (skillsCompleted / skillsTotal) * 100.0 
        : 0.0;
    weightedSum += skillsPercentage * 10;
    totalWeight += 10;

    // 4. Education (Weight: 15%)
    int educationCompleted = 0;
    int educationTotal = 1;
    if (education.isNotEmpty) {
      final hasValidEducation = education.any((edu) {
        final qualification = (edu['qualification'] ?? '').toString().trim();
        final institute = (edu['institute'] ?? '').toString().trim();
        return qualification.isNotEmpty || institute.isNotEmpty;
      });
      if (hasValidEducation) educationCompleted++;
    }
    final educationPercentage = educationTotal > 0 
        ? (educationCompleted / educationTotal) * 100.0 
        : 0.0;
    weightedSum += educationPercentage * 15;
    totalWeight += 15;

    // 5. Work Experience (Weight: 15%)
    int experienceCompleted = 0;
    int experienceTotal = 1;
    if (experience.isNotEmpty) {
      final hasValidExperience = experience.any((exp) {
        final company = (exp['company'] ?? '').toString().trim();
        final position = (exp['position'] ?? '').toString().trim();
        return company.isNotEmpty || position.isNotEmpty;
      });
      if (hasValidExperience) experienceCompleted++;
    }
    final experiencePercentage = experienceTotal > 0 
        ? (experienceCompleted / experienceTotal) * 100.0 
        : 0.0;
    weightedSum += experiencePercentage * 15;
    totalWeight += 15;

    // 6. Contact (Weight: 10%)
    int contactCompleted = 0;
    int contactTotal = 2;
    // Check contactEmail first, fallback to email from account info
    final contactEmail = _isNotEmpty(userProfile['contactEmail'])
        ? userProfile['contactEmail']
        : (_isNotEmpty(userProfile['email']) ? userProfile['email'] : null);
    if (_isNotEmpty(contactEmail)) contactCompleted++;
    // Check contactPhone first, fallback to phone from account info
    final contactPhone = _isNotEmpty(userProfile['contactPhone'])
        ? userProfile['contactPhone']
        : (_isNotEmpty(userProfile['phone']) ? userProfile['phone'] : null);
    if (_isNotEmpty(contactPhone)) contactCompleted++;
    final contactPercentage = contactTotal > 0 
        ? (contactCompleted / contactTotal) * 100.0 
        : 0.0;
    weightedSum += contactPercentage * 10;
    totalWeight += 10;

    // 7. Socials (Weight: 5%)
    int socialCompleted = 0;
    int socialTotal = 1;
    final socialLinks = userProfile['socialLinks'] ?? [];
    if (socialLinks is List && socialLinks.isNotEmpty) {
      final hasValidLink = socialLinks.any((link) {
        if (link is Map<String, dynamic>) {
          final title = (link['title'] ?? '').toString().trim();
          final url = (link['profile_url'] ?? '').toString().trim();
          return title.isNotEmpty && url.isNotEmpty;
        }
        return false;
      });
      if (hasValidLink) socialCompleted++;
    }
    final socialPercentage = socialTotal > 0 
        ? (socialCompleted / socialTotal) * 100.0 
        : 0.0;
    weightedSum += socialPercentage * 5;
    totalWeight += 5;

    // 8. Resume (Weight: 10%)
    int resumeCompleted = (resumeFileName != null && resumeFileName.isNotEmpty) ? 1 : 0;
    int resumeTotal = 1;
    final resumePercentage = resumeTotal > 0 
        ? (resumeCompleted / resumeTotal) * 100.0 
        : 0.0;
    weightedSum += resumePercentage * 10;
    totalWeight += 10;

    // 9. Certificates (Weight: 10%)
    int certificatesCompleted = certificates.isNotEmpty ? 1 : 0;
    int certificatesTotal = 1;
    final certificatesPercentage = certificatesTotal > 0 
        ? (certificatesCompleted / certificatesTotal) * 100.0 
        : 0.0;
    weightedSum += certificatesPercentage * 10;
    totalWeight += 10;

    // Calculate weighted average
    if (totalWeight == 0) return 0.0;
    return weightedSum / totalWeight;
  }

  /// Get completion details with breakdown
  static ProfileCompletionDetails getCompletionDetails({
    required Map<String, dynamic> userProfile,
    required List<String> skills,
    required List<Map<String, dynamic>> education,
    required List<Map<String, dynamic>> experience,
    required List<Map<String, dynamic>> certificates,
    String? resumeFileName,
    String? profileImagePath,
  }) {
    final percentage = calculateCompletionPercentage(
      userProfile: userProfile,
      skills: skills,
      education: education,
      experience: experience,
      certificates: certificates,
      resumeFileName: resumeFileName,
      profileImagePath: profileImagePath,
    );

    final sections = <CompletionSection>[];

    // 1. Profile Info (Profile header: image, name, email, phone, location, about me/bio)
    int profileInfoCompleted = 0;
    int profileInfoTotal = 6;
    if (profileImagePath != null && profileImagePath.isNotEmpty) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['userName']) || _isNotEmpty(userProfile['name'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['email'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['phone'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['location'])) profileInfoCompleted++;
    if (_isNotEmpty(userProfile['bio'])) profileInfoCompleted++;

    sections.add(CompletionSection(
      name: 'Profile Info',
      completed: profileInfoCompleted,
      total: profileInfoTotal,
      weight: 15,
    ));

    // 2. General Info (dateOfBirth, gender, languages, aadharNumber)
    int generalInfoCompleted = 0;
    int generalInfoTotal = 4;
    if (_isNotEmpty(userProfile['dateOfBirth'])) generalInfoCompleted++;
    if (_isNotEmpty(userProfile['gender'])) generalInfoCompleted++;
    if (_isNotEmptyList(userProfile['languages'])) generalInfoCompleted++;
    if (_isNotEmpty(userProfile['aadharNumber'])) generalInfoCompleted++;

    sections.add(CompletionSection(
      name: 'General Info',
      completed: generalInfoCompleted,
      total: generalInfoTotal,
      weight: 10,
    ));

    // 3. Skills and Expertise
    int skillsCompleted = 0;
    int skillsTotal = 1;
    if (skills.isNotEmpty) skillsCompleted++;

    sections.add(CompletionSection(
      name: 'Skills and Expertise',
      completed: skillsCompleted,
      total: skillsTotal,
      weight: 10,
    ));

    // 4. Education
    int educationCompleted = 0;
    int educationTotal = 1;
    if (education.isNotEmpty) {
      final hasValidEducation = education.any((edu) {
        final qualification = (edu['qualification'] ?? '').toString().trim();
        final institute = (edu['institute'] ?? '').toString().trim();
        return qualification.isNotEmpty || institute.isNotEmpty;
      });
      if (hasValidEducation) educationCompleted++;
    }

    sections.add(CompletionSection(
      name: 'Education',
      completed: educationCompleted,
      total: educationTotal,
      weight: 15,
    ));

    // 5. Work Experience
    int experienceCompleted = 0;
    int experienceTotal = 1;
    if (experience.isNotEmpty) {
      final hasValidExperience = experience.any((exp) {
        final company = (exp['company'] ?? '').toString().trim();
        final position = (exp['position'] ?? '').toString().trim();
        return company.isNotEmpty || position.isNotEmpty;
      });
      if (hasValidExperience) experienceCompleted++;
    }

    sections.add(CompletionSection(
      name: 'Work Experience',
      completed: experienceCompleted,
      total: experienceTotal,
      weight: 15,
    ));

    // 6. Contact
    int contactCompleted = 0;
    int contactTotal = 2;
    // Check contactEmail first, fallback to email from account info
    final contactEmail = _isNotEmpty(userProfile['contactEmail'])
        ? userProfile['contactEmail']
        : (_isNotEmpty(userProfile['email']) ? userProfile['email'] : null);
    if (_isNotEmpty(contactEmail)) contactCompleted++;
    // Check contactPhone first, fallback to phone from account info
    final contactPhone = _isNotEmpty(userProfile['contactPhone'])
        ? userProfile['contactPhone']
        : (_isNotEmpty(userProfile['phone']) ? userProfile['phone'] : null);
    if (_isNotEmpty(contactPhone)) contactCompleted++;

    sections.add(CompletionSection(
      name: 'Contact',
      completed: contactCompleted,
      total: contactTotal,
      weight: 10,
    ));

    // 7. Socials
    int socialCompleted = 0;
    int socialTotal = 1;
    final socialLinks = userProfile['socialLinks'] ?? [];
    if (socialLinks is List && socialLinks.isNotEmpty) {
      final hasValidLink = socialLinks.any((link) {
        if (link is Map<String, dynamic>) {
          final title = (link['title'] ?? '').toString().trim();
          final url = (link['profile_url'] ?? '').toString().trim();
          return title.isNotEmpty && url.isNotEmpty;
        }
        return false;
      });
      if (hasValidLink) socialCompleted++;
    }

    sections.add(CompletionSection(
      name: 'Socials',
      completed: socialCompleted,
      total: socialTotal,
      weight: 5,
    ));

    // 8. Resume
    int resumeCompleted = 0;
    int resumeTotal = 1;
    if (resumeFileName != null && resumeFileName.isNotEmpty) resumeCompleted++;

    sections.add(CompletionSection(
      name: 'Resume',
      completed: resumeCompleted,
      total: resumeTotal,
      weight: 10,
    ));

    // 9. Certificates
    int certificatesCompleted = 0;
    int certificatesTotal = 1;
    if (certificates.isNotEmpty) certificatesCompleted++;

    sections.add(CompletionSection(
      name: 'Certificates',
      completed: certificatesCompleted,
      total: certificatesTotal,
      weight: 10,
    ));

    return ProfileCompletionDetails(
      percentage: percentage,
      sections: sections,
    );
  }

  /// Helper to check if a value is not empty
  static bool _isNotEmpty(dynamic value) {
    if (value == null) return false;
    if (value is String) return value.trim().isNotEmpty;
    return true;
  }

  /// Helper to check if a list is not empty
  static bool _isNotEmptyList(dynamic value) {
    if (value == null) return false;
    if (value is List) return value.isNotEmpty;
    if (value is String) {
      final list = value.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      return list.isNotEmpty;
    }
    return false;
  }
}

/// Profile completion details
class ProfileCompletionDetails {
  final double percentage;
  final List<CompletionSection> sections;

  ProfileCompletionDetails({
    required this.percentage,
    required this.sections,
  });
}

/// Completion section details
class CompletionSection {
  final String name;
  final int completed;
  final int total;
  final int weight; // Weight percentage

  CompletionSection({
    required this.name,
    required this.completed,
    required this.total,
    required this.weight,
  });

  double get percentage => total > 0 ? (completed / total) * 100.0 : 0.0;
}

