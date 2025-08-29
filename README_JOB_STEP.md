# Job Step Screen

## Overview
The `JobStepScreen` is a single-step job application page that allows students to:
- Enter their personal information (name, email, phone number)
- Upload and manage their resume/CV documents
- Submit their application and proceed to skill tests

## Features

### 1. Personal Information Form
- **Full Name**: Required field with validation
- **Email Address**: Required field with email format validation
- **Phone Number**: Required field with minimum length validation

### 2. Document Upload
- **Resume/CV Upload**: Single combined field supporting PDF, DOC, DOCX files (max 5MB)
- **Pre-loaded Files**: Existing Resume/CV is automatically loaded from user profile
- **File Management**: View, edit, replace, and remove uploaded files
- **Document Preview**: Visual preview of the uploaded document
- **Validation**: Resume/CV document is required before submission

### 3. Existing Documents
- **Auto-loading**: Resume/CV file is automatically loaded from user profile
- **Visual Indicators**: Existing file is marked with "Existing" badge
- **Document Preview**: Visual preview shows document information and allows full viewing
- **Flexible Management**: Users can keep existing file or replace it with a new one
- **Clear Instructions**: Helpful text explains how to manage existing document

### 4. User Experience
- **Bilingual Labels**: English and Hindi text for better accessibility
- **Progress Indicator**: Shows completion status (100% for single step)
- **Form Validation**: Real-time validation with error messages
- **Loading States**: Submit button shows loading indicator during submission

## Navigation Flow

### From Job Details
1. User views a job in `JobDetailsScreen`
2. Taps "Apply This Job" button
3. Chooses "Apply Directly" from the dialog
4. Navigates to `JobStepScreen` with job data

### After Submission
1. User fills form and uploads documents
2. Taps "Submit Application & Take Skill Test"
3. Application is processed
4. Automatically navigates to `SkillTestDetailsScreen`

## File Structure

```
lib/pages/jobs/
├── job_step.dart          # Main job step screen
├── job_details.dart       # Updated to include navigation option
└── ...
```

## Dependencies

- `file_picker: ^8.0.0+1` - For document upload functionality
- `flutter/material.dart` - Core Flutter widgets
- Custom app constants and navigation service

## Usage Example

```dart
// Navigate to job step screen
NavigationService.smartNavigate(
  destination: JobStepScreen(job: jobData),
);

// Or use direct navigation
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => JobStepScreen(job: jobData),
  ),
);
```

## Design Features

- **Modern UI**: Clean, card-based design with proper spacing
- **Responsive Layout**: Adapts to different screen sizes
- **Color Scheme**: Uses app's consistent color palette
- **Icons**: Meaningful icons for better visual hierarchy
- **Typography**: Consistent text styles and sizes

## Validation Rules

1. **Name**: Required, non-empty
2. **Email**: Required, valid email format
3. **Phone**: Required, minimum 10 characters
4. **Resume/CV**: Required, PDF/DOC/DOCX, max 5MB

## Error Handling

- Form validation errors displayed below each field
- File size limit warnings
- Network error handling for file uploads
- User-friendly error messages in both English and Hindi

## Future Enhancements

- File preview functionality
- Multiple file format support
- Cloud storage integration
- Application status tracking
- Email confirmation system
