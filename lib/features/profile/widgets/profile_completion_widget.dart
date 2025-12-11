import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';
import '../services/profile_completion_service.dart';

/// Profile Completion Widget
/// Displays profile completion percentage with visual progress indicator
class ProfileCompletionWidget extends StatelessWidget {
  final double completionPercentage;
  final ProfileCompletionDetails? completionDetails;
  final VoidCallback? onTap;

  const ProfileCompletionWidget({
    super.key,
    required this.completionPercentage,
    this.completionDetails,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: AppConstants.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppConstants.smallPadding),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile Completion',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getCompletionMessage(completionPercentage),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Percentage Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getCompletionColor(completionPercentage)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getCompletionColor(completionPercentage)
                          .withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '${completionPercentage.round()}%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getCompletionColor(completionPercentage),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.defaultPadding),
            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: completionPercentage / 100,
                minHeight: 8,
                backgroundColor: AppConstants.backgroundColor,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getCompletionColor(completionPercentage),
                ),
              ),
            ),
            // Section Breakdown (if details provided)
            if (completionDetails != null) ...[
              const SizedBox(height: AppConstants.defaultPadding),
              ...completionDetails!.sections.map((section) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          section.name,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ),
                      Text(
                        '${section.completed}/${section.total}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: section.percentage == 100
                              ? AppConstants.successColor
                              : AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  /// Get completion message based on percentage
  String _getCompletionMessage(double percentage) {
    if (percentage >= 70) {
      return 'Excellent! Your profile is almost complete';
    } else if (percentage >= 50) {
      return 'You\'re halfway there!';
    } else if (percentage >= 30) {
      return 'Getting started! Add more details';
    } else {
      return 'Complete your profile to get noticed';
    }
  }

  /// Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 70) {
      return AppConstants.successColor;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

/// Expandable Profile Completion Widget
/// Shows detailed breakdown when expanded
class ExpandableProfileCompletionWidget extends StatefulWidget {
  final double completionPercentage;
  final ProfileCompletionDetails completionDetails;

  const ExpandableProfileCompletionWidget({
    super.key,
    required this.completionPercentage,
    required this.completionDetails,
  });

  @override
  State<ExpandableProfileCompletionWidget> createState() =>
      _ExpandableProfileCompletionWidgetState();
}

class _ExpandableProfileCompletionWidgetState
    extends State<ExpandableProfileCompletionWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final completionColor = _getCompletionColor(widget.completionPercentage);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            completionColor.withValues(alpha: 0.08),
            completionColor.withValues(alpha: 0.03),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: completionColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: completionColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header (always visible)
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: completionColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: completionColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: completionColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppConstants.smallPadding),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Profile Completion',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppConstants.textPrimaryColor,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getCompletionMessage(widget.completionPercentage),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Percentage Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: completionColor,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: completionColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      '${widget.completionPercentage.round()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: completionColor,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Progress Bar (always visible)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              0,
              AppConstants.defaultPadding,
              AppConstants.defaultPadding,
            ),
            child: Stack(
              children: [
                Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppConstants.backgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: widget.completionPercentage / 100,
                    minHeight: 12,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      completionColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Expandable Section Breakdown
          if (_isExpanded) ...[
            Container(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                0,
                AppConstants.defaultPadding,
                AppConstants.defaultPadding,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(AppConstants.borderRadius),
                  bottomRight: Radius.circular(AppConstants.borderRadius),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Divider(
                    color: completionColor.withValues(alpha: 0.2),
                    thickness: 1,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Icon(
                        Icons.analytics_outlined,
                        color: completionColor,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Completion Breakdown',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...widget.completionDetails.sections.map((section) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  section.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    color: AppConstants.textPrimaryColor,
                                  ),
                                ),
                              ),
                              Text(
                                '${section.completed}/${section.total}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: section.percentage == 100
                                      ? AppConstants.successColor
                                      : section.percentage == 0
                                          ? AppConstants.textSecondaryColor
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: section.percentage / 100,
                              minHeight: 4,
                              backgroundColor: AppConstants.backgroundColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                section.percentage == 100
                                    ? AppConstants.successColor
                                    : section.percentage == 0
                                        ? Colors.grey.shade300
                                        : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get completion message based on percentage
  String _getCompletionMessage(double percentage) {
    if (percentage >= 70) {
      return 'Excellent! Your profile is almost complete';
    } else if (percentage >= 50) {
      return 'You\'re halfway there!';
    } else if (percentage >= 30) {
      return 'Getting started! Add more details';
    } else {
      return 'Complete your profile to get noticed';
    }
  }

  /// Get color based on completion percentage
  Color _getCompletionColor(double percentage) {
    if (percentage >= 70) {
      return AppConstants.successColor;
    } else if (percentage >= 50) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}

