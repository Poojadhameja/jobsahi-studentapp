import 'package:flutter/material.dart';
import '../../../../core/utils/app_constants.dart';

class SkillsEditScreen extends StatefulWidget {
  final List<String>? initialSkills;

  const SkillsEditScreen({super.key, this.initialSkills});

  @override
  State<SkillsEditScreen> createState() => _SkillsEditScreenState();
}

class _SkillsEditScreenState extends State<SkillsEditScreen> {
  final _skillController = TextEditingController();
  List<String> _skills = [];
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
  void initState() {
    super.initState();
    _skills = List.from(widget.initialSkills ?? []);
  }

  @override
  void dispose() {
    _skillController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() {
        _skills.add(skill);
        _skillController.clear();
      });
    }
  }

  void _removeSkill(String skill) {
    setState(() {
      _skills.remove(skill);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Skills'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement save functionality
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
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
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addSkill,
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
                    if (selected && !_skills.contains(skill)) {
                      setState(() {
                        _skills.add(skill);
                      });
                    }
                  },
                  selected: _skills.contains(skill),
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
              children: _skills.map((skill) {
                return Chip(
                  label: Text(skill),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () => _removeSkill(skill),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
