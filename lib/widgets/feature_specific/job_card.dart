import 'package:flutter/material.dart';
import '../../utils/app_constants.dart';

class JobCard extends StatefulWidget {
  /// Job data to be displayed
  final Map<String, dynamic> job;

  /// Callback function when the card is tapped
  final VoidCallback? onTap;

  /// Whether to show the save button (default: true)
  final bool showSaveButton;

  /// Whether the job is initially saved (default: false)
  final bool isInitiallySaved;

  const JobCard({
    super.key,
    required this.job,
    this.onTap,
    this.showSaveButton = true,
    this.isInitiallySaved = false,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  /// Tracks whether the job is saved by the user
  late bool isSaved;

  @override
  void initState() {
    super.initState();
    // Initialize saved state
    isSaved = widget.isInitiallySaved;
  }

  /// Toggle the saved state of the job
  void _toggleSaved() {
    setState(() {
      isSaved = !isSaved;
    });
    // TODO: Call API to save/unsave job
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppConstants.defaultPadding),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppConstants.cardBackgroundColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job header with company logo, title, company name, rating, and save button
            _buildJobHeader(job),
            const SizedBox(height: 12),

            // Job tags
            _buildJobTags(job),
            const SizedBox(height: 10),

            // Salary information
            _buildSalaryInfo(job),
            const SizedBox(height: 4),

            // Location and time information
            _buildLocationAndTime(job),
          ],
        ),
      ),
    );
  }

  /// Builds the job header section with logo, title, company, rating, and save button
  Widget _buildJobHeader(Map<String, dynamic> job) {
    return Row(
      children: [
        // Company logo
        Image.asset(
          job['logo'] ?? AppConstants.defaultCompanyLogo,
          width: 40,
          height: 40,
        ),
        const SizedBox(width: 10),

        // Job title and company name
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job['title'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                job['company'] ?? '',
                style: const TextStyle(color: AppConstants.accentColor),
              ),
            ],
          ),
        ),

        // Rating
        Column(
          children: [
            const Icon(Icons.star, color: Colors.orange, size: 16),
            Text(job['rating']?.toString() ?? '0'),
          ],
        ),
        const SizedBox(width: 12),

        // Save button (optional)
        if (widget.showSaveButton) _buildSaveButton(),
      ],
    );
  }

  /// Builds the save button
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _toggleSaved,
      child: Column(
        children: [
          Icon(
            isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: AppConstants.accentColor,
          ),
          const SizedBox(height: 4),
          Text(
            isSaved ? AppConstants.savedText : AppConstants.saveText,
            style: const TextStyle(
              fontSize: 12,
              color: AppConstants.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the job tags section
  Widget _buildJobTags(Map<String, dynamic> job) {
    final tags = job['tags'] as List<dynamic>? ?? [];

    return Row(
      children: tags
          .map<Widget>(
            (tag) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: JobTag(text: tag.toString()),
            ),
          )
          .toList(),
    );
  }

  /// Builds the salary information section
  Widget _buildSalaryInfo(Map<String, dynamic> job) {
    return Text(
      job['salary'] ?? '',
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  /// Builds the location and time information section
  Widget _buildLocationAndTime(Map<String, dynamic> job) {
    return Row(
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppConstants.textSecondaryColor,
        ),
        const SizedBox(width: 4),
        Text(job['location'] ?? ''),
        const Spacer(),
        Text(
          job['time'] ?? '',
          style: const TextStyle(color: AppConstants.textSecondaryColor),
        ),
      ],
    );
  }
}

/// Job Tag Widget
/// Displays individual job tags like "Full-Time", "Apprenticeship", etc.
class JobTag extends StatelessWidget {
  /// Text to be displayed in the tag
  final String text;

  const JobTag({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppConstants.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: AppConstants.accentColor),
      ),
    );
  }
}
