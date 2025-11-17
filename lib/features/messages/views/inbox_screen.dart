import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/app_constants.dart';
import '../../../shared/widgets/common/profile_navigation_app_bar.dart';
import '../../../shared/widgets/common/keyboard_dismiss_wrapper.dart';
import '../bloc/messages_bloc.dart';
import '../bloc/messages_event.dart';

class InboxScreen extends StatelessWidget {
  /// Whether this screen is opened from profile navigation
  final bool isFromProfile;

  const InboxScreen({super.key, this.isFromProfile = false});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MessagesBloc()..add(const LoadMessagesEvent()),
      child: _InboxScreenView(isFromProfile: isFromProfile),
    );
  }
}

class _InboxScreenView extends StatelessWidget {
  final bool isFromProfile;

  const _InboxScreenView({required this.isFromProfile});
  @override
  Widget build(BuildContext context) {
    return KeyboardDismissWrapper(
      child: Scaffold(
        backgroundColor: AppConstants.cardBackgroundColor,
        appBar: isFromProfile
            ? ProfileNavigationAppBar(title: 'Messages')
            : null,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.construction_outlined,
                  size: 80,
                  color: AppConstants.textSecondaryColor.withOpacity(0.5),
                ),
                const SizedBox(height: 24),
                Text(
                  'Coming Soon',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textPrimaryColor,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    'We are working on this feature. It will be available soon!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
