import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

/// Modern Profile Header Card Widget
/// Can be used in menu, profile details, and other screens
class ProfileHeaderCard extends StatelessWidget {
  final String name;
  final String email;
  final String? location;
  final String? profileImagePath;
  final VoidCallback? onTap;
  final bool showEditButton;
  final VoidCallback? onEditPressed;
  final bool isCompact;

  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.location,
    this.profileImagePath,
    this.onTap,
    this.showEditButton = false,
    this.onEditPressed,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConstants.primaryColor,
            AppConstants.primaryColor.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: AppConstants.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Padding(
            padding: EdgeInsets.all(
              isCompact
                  ? AppConstants.defaultPadding
                  : AppConstants.largePadding,
            ),
            child: Column(
              children: [
                // Profile Image and Info Row
                Row(
                  children: [
                    // Profile Image with Status
                    Stack(
                      children: [
                        Container(
                          width: isCompact ? 60 : 80,
                          height: isCompact ? 60 : 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: isCompact ? 27 : 37,
                            backgroundColor: Colors.white,
                            child: profileImagePath != null
                                ? ClipOval(
                                    child: Image.asset(
                                      profileImagePath!,
                                      fit: BoxFit.cover,
                                      width: isCompact ? 54 : 74,
                                      height: isCompact ? 54 : 74,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return _buildDefaultProfileImage(
                                              isCompact,
                                            );
                                          },
                                    ),
                                  )
                                : _buildDefaultProfileImage(isCompact),
                          ),
                        ),
                        // Online Status Indicator
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            width: isCompact ? 16 : 20,
                            height: isCompact ? 16 : 20,
                            decoration: BoxDecoration(
                              color: AppConstants.successColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppConstants.defaultPadding),

                    // User Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isCompact ? 18 : 22,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isCompact ? 14 : 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (location != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: Colors.white.withValues(alpha: 0.8),
                                  size: isCompact ? 14 : 16,
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    location!,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: isCompact ? 12 : 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Edit Button
                    if (showEditButton)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: onEditPressed,
                        tooltip: 'Edit Profile',
                      ),
                  ],
                ),

                // Bio Section (only for non-compact mode)
                if (!isCompact) ...[
                  const SizedBox(height: AppConstants.defaultPadding),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppConstants.defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.smallBorderRadius,
                      ),
                    ),
                    child: Text(
                      'Passionate about technology and innovation. Always learning and growing.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultProfileImage(bool isCompact) {
    return Container(
      color: AppConstants.backgroundColor,
      child: Icon(
        Icons.person,
        size: isCompact ? 30 : 40,
        color: AppConstants.textSecondaryColor,
      ),
    );
  }
}

/// Compact Profile Header for use in smaller spaces
class CompactProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String? profileImagePath;
  final VoidCallback? onTap;

  const CompactProfileHeader({
    super.key,
    required this.name,
    required this.email,
    this.profileImagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          child: Row(
            children: [
              // Profile Image
              CircleAvatar(
                radius: 25,
                backgroundColor: AppConstants.primaryColor.withValues(
                  alpha: 0.1,
                ),
                child: profileImagePath != null
                    ? ClipOval(
                        child: Image.asset(
                          profileImagePath!,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              color: AppConstants.primaryColor,
                              size: 25,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.person,
                        color: AppConstants.primaryColor,
                        size: 25,
                      ),
              ),
              const SizedBox(width: AppConstants.defaultPadding),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppConstants.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Arrow Icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
