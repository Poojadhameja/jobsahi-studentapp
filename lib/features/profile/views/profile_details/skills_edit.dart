import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/app_constants.dart';
import '../../bloc/profile_bloc.dart';
import '../../bloc/profile_event.dart';
import '../../bloc/profile_state.dart';

class SkillsEditScreen extends StatelessWidget {
  final List<String>? initialSkills;

  const SkillsEditScreen({super.key, this.initialSkills});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          ProfileBloc()
            ..add(UpdateSkillsListEvent(skills: initialSkills ?? [])),
      child: _SkillsEditScreenView(initialSkills: initialSkills),
    );
  }
}

class _SkillsEditScreenView extends StatefulWidget {
  final List<String>? initialSkills;

  const _SkillsEditScreenView({this.initialSkills});

  @override
  State<_SkillsEditScreenView> createState() => _SkillsEditScreenViewState();
}

class _SkillsEditScreenViewState extends State<_SkillsEditScreenView> {
  final _skillController = TextEditingController();
  final List<String> _suggestedSkills = [
    'Flutter',
    'Dart',
    'React',
    'JavaScript',
    'Python',
    'Java',
    'C++',
    'HTML',
    'CSS',
    'Node.js',
    'MongoDB',
    'SQL',
    'Git',
    'AWS',
    'Firebase',
    'UI/UX Design',
    'Project Management',
    'Communication',
    'Leadership',
  ];

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill(BuildContext context, List<String> currentSkills) {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !currentSkills.contains(skill)) {
      final updatedSkills = [...currentSkills, skill];
      context.read<ProfileBloc>().add(
        UpdateSkillsListEvent(skills: updatedSkills),
      );
      _skillController.clear();
    }
  }

  void _removeSkill(
    BuildContext context,
    String skill,
    List<String> currentSkills,
  ) {
    final updatedSkills = currentSkills.where((s) => s != skill).toList();
    context.read<ProfileBloc>().add(
      UpdateSkillsListEvent(skills: updatedSkills),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is SkillsChangesSavedState) {
          Navigator.pop(context);
        }
      },
      child: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          List<String> skills = widget.initialSkills ?? [];
          bool isSaving = false;

          if (state is SkillsEditFormState) {
            skills = state.skills;
            isSaving = state.isSaving;
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Edit Skills'),
              backgroundColor: AppConstants.primaryColor,
              foregroundColor: Colors.white,
              actions: [
                TextButton(
                  onPressed: isSaving
                      ? null
                      : () {
                          context.read<ProfileBloc>().add(
                            const SaveSkillsChangesEvent(),
                          );
                        },
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
                      : const Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _skillController,
                          decoration: const InputDecoration(
                            labelText: 'Add Skill',
                            border: OutlineInputBorder(),
                          ),
                          onFieldSubmitted: (_) => _addSkill(context, skills),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addSkill(context, skills),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Suggested Skills:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedSkills.map((skill) {
                      return FilterChip(
                        label: Text(skill),
                        onSelected: (selected) {
                          if (selected && !skills.contains(skill)) {
                            final updatedSkills = [...skills, skill];
                            context.read<ProfileBloc>().add(
                              UpdateSkillsListEvent(skills: updatedSkills),
                            );
                          }
                        },
                        selected: skills.contains(skill),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Your Skills:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: skills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () => _removeSkill(context, skill, skills),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
