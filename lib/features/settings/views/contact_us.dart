import 'package:flutter/material.dart';
import '../../../core/utils/app_constants.dart';

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
                      onPressed: () => Navigator.of(context).pop(),
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
                    _buildContactSection(),
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

  Widget _buildContactSection() {
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
            'www.jobsahi.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
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
              Text(
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
}


