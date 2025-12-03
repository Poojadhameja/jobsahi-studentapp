import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/top_snackbar.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.largePadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: AppConstants.textPrimaryColor,
                      ),
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    Center(
                      child: Column(
                        children: [
                          const CircleAvatar(
                            radius: 40,
                            backgroundColor: Color(0xFFE0E7EF),
                            child: Icon(
                              Icons.support_agent_outlined,
                              size: 45,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Contact Us",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppConstants.textPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "We’re here to help",
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF4F789B),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildContactSection(context),
                    const SizedBox(height: 20),
                    _buildQuickLinksSection(context),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(Icons.email_outlined, 'Email', 'info@jobsahi.com'),
          const SizedBox(height: 8),
          _buildContactRow(Icons.phone_outlined, 'Phone', '+91 12345 67890'),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.location_on_outlined,
            'Address',
            'Central India',
          ),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.language_outlined,
            'Website',
            'Visit Website',
            isClickable: true,
            onTap: () => _openWebsite(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    IconData icon,
    String label,
    String value, {
    bool isClickable = false,
    VoidCallback? onTap,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF58B248)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
              isClickable
                  ? GestureDetector(
                      onTap: onTap,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            value,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.open_in_new,
                            size: 16,
                            color: AppConstants.primaryColor,
                          ),
                        ],
                      ),
                    )
                  : Text(
                      value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickLinksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Links',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildContactRow(
            Icons.chat,
            'WhatsApp',
            'Open WhatsApp',
            isClickable: true,
            onTap: () => _openWhatsApp(context),
          ),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.public,
            'Facebook',
            'Visit Facebook Page',
            isClickable: true,
            onTap: () => _openFacebook(context),
          ),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.photo_camera,
            'Instagram',
            'Visit Instagram Profile',
            isClickable: true,
            onTap: () => _openInstagram(context),
          ),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.work,
            'LinkedIn',
            'Visit LinkedIn Profile',
            isClickable: true,
            onTap: () => _openLinkedIn(context),
          ),
        ],
      ),
    );
  }


  Future<void> _openWhatsApp(BuildContext context) async {
    // Replace with your WhatsApp number (format: country code + number without +)
    const whatsappNumber = '911234567890';
    final whatsappUrl = 'https://wa.me/$whatsappNumber';

    try {
      final uri = Uri.parse(whatsappUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open WhatsApp. Please try again.',
        );
      }
    }
  }

  Future<void> _openFacebook(BuildContext context) async {
    // Replace with your Facebook page URL
    const facebookUrl = 'https://www.facebook.com/jobsahi';

    try {
      final uri = Uri.parse(facebookUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open Facebook. Please try again.',
        );
      }
    }
  }

  Future<void> _openInstagram(BuildContext context) async {
    // Replace with your Instagram profile URL
    const instagramUrl = 'https://www.instagram.com/jobsahi';

    try {
      final uri = Uri.parse(instagramUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open Instagram. Please try again.',
        );
      }
    }
  }

  Future<void> _openLinkedIn(BuildContext context) async {
    // Replace with your LinkedIn company/profile URL
    const linkedInUrl = 'https://www.linkedin.com/company/jobsahi';

    try {
      final uri = Uri.parse(linkedInUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open LinkedIn. Please try again.',
        );
      }
    }
  }

  Future<void> _openWebsite(BuildContext context) async {
    const websiteUrl = 'https://www.google.com';

    try {
      final uri = Uri.parse(websiteUrl);

      // Try launching URL directly - canLaunchUrl can be unreliable
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        // If external application mode fails, try platform default
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      if (context.mounted) {
        TopSnackBar.showError(
          context,
          message: 'Could not open website. Please try again.',
        );
      }
    }
  }
}
