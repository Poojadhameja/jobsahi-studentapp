import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_constants.dart';
import '../../../../shared/data/user_data.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

class ProfileEditScreen extends StatelessWidget {
  const ProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()
        ..add(
          UpdateProfileEditFormEvent(
            name: UserData.currentUser['name'] ?? '',
            email: UserData.currentUser['email'] ?? '',
            phone: UserData.currentUser['phone'] ?? '',
          ),
        ),
      child: const _ProfileEditScreenView(),
    );
  }
}

class _ProfileEditScreenView extends StatefulWidget {
  const _ProfileEditScreenView();

  @override
  State<_ProfileEditScreenView> createState() => _ProfileEditScreenViewState();
}

class _ProfileEditScreenViewState extends State<_ProfileEditScreenView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with current user data
    _nameController.text = UserData.currentUser['name'] ?? '';
    _emailController.text = UserData.currentUser['email'] ?? '';
    _phoneController.text = UserData.currentUser['phone'] ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileChangesSavedState) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          bool isSaving = false;
          if (state is ProfileEditFormState) {
            isSaving = state.isSaving;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Profile'),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          UpdateProfileEditFormEvent(
                            name: value,
                            email: _emailController.text,
                            phone: _phoneController.text,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          UpdateProfileEditFormEvent(
                            name: _nameController.text,
                            email: value,
                            phone: _phoneController.text,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your phone number';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        context.read<ProfileBloc>().add(
                          UpdateProfileEditFormEvent(
                            name: _nameController.text,
                            email: _emailController.text,
                            phone: value,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSaving
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<ProfileBloc>().add(
                                    const SaveProfileChangesEvent(),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: isSaving
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Save Changes'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
