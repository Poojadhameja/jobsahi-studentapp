import 'package:flutter/material.dart';
import '../../../../core/utils/app_constants.dart';

class CertificatesEditScreen extends StatefulWidget {
  const CertificatesEditScreen({super.key});

  @override
  State<CertificatesEditScreen> createState() => _CertificatesEditScreenState();
}

class _CertificatesEditScreenState extends State<CertificatesEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _issuerController = TextEditingController();
  final _dateController = TextEditingController();
  final _credentialIdController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _issuerController.dispose();
    _dateController.dispose();
    _credentialIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Certificate'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Certificate Name',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., AWS Certified Solutions Architect',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter certificate name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _issuerController,
                  decoration: const InputDecoration(
                    labelText: 'Issuing Organization',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., Amazon Web Services',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter issuing organization';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Issue Date',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select issue date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _credentialIdController,
                  decoration: const InputDecoration(
                    labelText: 'Credential ID (Optional)',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., AWS-123456789',
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // TODO: Implement save functionality
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Save Certificate'),
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
