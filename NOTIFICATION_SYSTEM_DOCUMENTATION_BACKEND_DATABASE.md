# Notification System Documentation

## 📋 Overview
Yeh documentation notification system ke complete implementation ko cover karti hai, including database tables, API endpoints, aur frontend integration ke liye required information.

### ⚠️ Important: Students Only
**Notification system abhi sirf students ke liye hai.**
- ✅ Push notifications sirf students ko bheje jate hain
- ✅ FCM tokens sirf students ke store hote hain
- ✅ Automatic notifications (shortlisted, new job) sirf students ke liye
- ✅ App access sirf students ka (recruiter/institute/admin app access nahi kar sakte)

---

## 🗄️ Database Tables

### 1. `notifications` Table
Notification messages ko store karne ke liye use hoti hai.

#### Table Structure:
```sql
CREATE TABLE `notifications` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `message` text DEFAULT NULL,
  `type` varchar(50) DEFAULT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` datetime DEFAULT current_timestamp(),
  `received_role` enum('student','recruiter','institute','admin') DEFAULT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### Columns Description:
- **id**: Primary key, auto-increment
- **user_id**: Notification receiver ka user ID (foreign key to `users.id`)
- **receiver_id**: Optional - specific receiver ID
- **message**: Notification message text
- **type**: Notification type (e.g., 'shortlisted', 'new_job', 'general', 'system', 'reminder', 'alert')
- **is_read**: Read status (0 = unread, 1 = read)
- **created_at**: Notification creation timestamp
- **received_role**: Receiver ka role (student, recruiter, institute, admin)

---

### 2. `notifications_templates` Table
Notification templates ko store karne ke liye use hoti hai (reusable message templates).

#### Table Structure:
```sql
CREATE TABLE `notifications_templates` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(100) DEFAULT NULL,
  `type` enum('email','sms','push') DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `body` text DEFAULT NULL,
  `created_at` datetime DEFAULT current_timestamp(),
  `role` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### Columns Description:
- **id**: Primary key, auto-increment
- **name**: Template ka name
- **type**: Template type (email, sms, push)
- **subject**: Email/SMS subject line
- **body**: Template body/message content
- **created_at**: Template creation timestamp
- **role**: Target role (optional)

---

### 3. `fcm_tokens` Table
Firebase Cloud Messaging (FCM) tokens ko store karne ke liye use hoti hai push notifications ke liye.

#### Table Structure:
```sql
CREATE TABLE `fcm_tokens` (
  `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `user_id` int(10) UNSIGNED NOT NULL,
  `fcm_token` text NOT NULL,
  `device_type` varchar(50) DEFAULT NULL COMMENT 'android, ios, web',
  `device_id` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` datetime DEFAULT current_timestamp(),
  `updated_at` datetime DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_user_device` (`user_id`, `device_id`),
  KEY `idx_user_id` (`user_id`),
  KEY `idx_fcm_token` (`fcm_token`(255)),
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

#### Columns Description:
- **id**: Primary key, auto-increment
- **user_id**: User ka ID (foreign key to `users.id`)
- **fcm_token**: Firebase Cloud Messaging token
- **device_type**: Device type (android, ios, web)
- **device_id**: Unique device identifier
- **is_active**: Token active status (1 = active, 0 = inactive)
- **created_at**: Token creation timestamp
- **updated_at**: Token last update timestamp

---

## 🔧 Backend Setup Guide

### Step 1: Firebase Service Account Setup

Backend se automatic notifications bhejne ke liye Firebase Service Account setup karna zaroori hai.

#### Firebase Console Steps:

1. **Firebase Console mein jao**:
   - URL: https://console.firebase.google.com/
   - Project: `jobsahi-app-notifications`

2. **Project Settings kholo**:
   - Gear icon (⚙️) click karo
   - "Project settings" select karo

3. **Service Account tab**:
   - "Service accounts" tab par jao
   - "Generate new private key" button click karo
   - JSON file download ho jayega

4. **Backend mein save karo**:
   - File ko backend server par save karo
   - **Path**: `api/config/firebase-service-account.json`
   - ⚠️ **Important**: Is file ko `.gitignore` mein add karo (sensitive data hai)

#### File Structure:
```
api/
├── config/
│   └── firebase-service-account.json  ← Yahan save karo
├── helpers/
│   ├── firebase_helper_v1.php
│   └── notification_helper.php
└── ...
```

#### Security Note:
```gitignore
# .gitignore mein add karo
api/config/firebase-service-account.json
config/firebase-service-account.json
```

---

### Step 2: Backend Helper Classes

Backend mein already helper classes available hain:

#### 1. FirebaseHelperV1 Class
**File**: `api/helpers/firebase_helper_v1.php`

Yeh class FCM v1 API use karti hai Service Account JSON ke through:
- OAuth2 access token automatically generate karta hai
- JWT signing handle karta hai
- Token caching (1 hour expiry)
- Multiple devices ko notifications send kar sakta hai

**Key Methods**:
- `sendToDevice($fcmToken, $title, $body, $data = [])` - Single device
- `sendToMultipleDevices($tokens, $title, $body, $data = [])` - Multiple devices

#### 2. NotificationHelper Class
**File**: `api/helpers/notification_helper.php`

Yeh class notification business logic handle karti hai:

**Available Methods**:

```php
// 1. Student ko shortlisted notification
NotificationHelper::notifyShortlisted($student_user_id, $job_title, $job_id);

// 2. Saare students ko new job notification
NotificationHelper::notifyNewJobPosted($job_title, $job_id, $location = '');

// 3. User ke FCM tokens fetch karo (sirf students)
NotificationHelper::getUserFCMTokens($user_id);

// 4. Saare students ke FCM tokens fetch karo
NotificationHelper::getAllStudentFCMTokens();
```

**Important**: `getAllStudentFCMTokens()` method sirf students ke tokens fetch karta hai:
```php
// Query: WHERE u.role = 'student' AND ft.is_active = 1
```

---

### Step 3: Automatic Notification Triggers

System automatically notifications send karta hai yeh events par:

#### A. Job Application Shortlisted

**File**: `api/applications/update_application_status.php`

**Code Location**: Lines 89-121

```php
// ✅ Send notification if student is shortlisted
// ⚠️ Note: Notifications are sent ONLY to students
if ($new_status === 'shortlisted') {
    // Get student user_id from application
    $student_sql = "
        SELECT sp.user_id, j.title as job_title, j.id as job_id
        FROM applications a
        JOIN student_profiles sp ON a.student_id = sp.id
        JOIN jobs j ON a.job_id = j.id
        WHERE a.id = ?
    ";
    // ... fetch student data ...
    
    // ✅ Send notification to student (students only)
    require_once '../helpers/notification_helper.php';
    $notification_result = NotificationHelper::notifyShortlisted($student_user_id, $job_title, $job_id);
}
```

**Recipient**: ✅ Sirf student (application owner)

**Code Comments**: File mein clear comments add kiye gaye hain jo students-only implementation ko indicate karte hain.

---

#### B. New Job Posted

**File**: `api/admin/update_job_status.php`

**Code Location**: Lines 52-65

```php
// ✅ Send notification to all students when job is approved
// ⚠️ Note: Notifications are sent ONLY to all active students
if ($admin_action === 'approved') {
    require_once '../helpers/notification_helper.php';
    // ✅ This sends notification to ALL active students only
    $notification_result = NotificationHelper::notifyNewJobPosted(
        $updatedJob['title'],
        $updatedJob['job_id'],
        $updatedJob['location'] ?? ''
    );
}
```

**Recipient**: ✅ Saare active students (batch processing - 1000 tokens per batch)

**Code Comments**: File mein clear comments add kiye gaye hain jo students-only implementation ko indicate karte hain.

**Query Logic**:
```php
// Sirf students ke tokens fetch hote hain
SELECT DISTINCT fcm_token 
FROM fcm_tokens ft
INNER JOIN users u ON ft.user_id = u.id
WHERE u.role = 'student' 
  AND ft.is_active = 1
  AND u.status = 'active'
  AND u.is_verified = 1
```

---

#### C. Interview Scheduled

**File**: `api/applications/schedule_interview.php`

**Code Location**: Lines 289-311

```php
// ✅ Step 5.5: Send notification to student if not already sent
// ⚠️ Note: Notifications are sent ONLY to students
// Get student user_id and job details
// ... fetch student data ...

// ✅ Send notification to student (students only)
require_once '../helpers/notification_helper.php';
$notification_result = NotificationHelper::notifyShortlisted($student_user_id, $job_title, $job_id);
```

**Recipient**: ✅ Sirf student

**Code Comments**: File mein clear comments add kiye gaye hain jo students-only implementation ko indicate karte hain.

---

### Step 4: Testing Backend Setup

#### Test Firebase Configuration:

```bash
# Test file run karo
php api/test_firebase_v1.php
```

Expected output:
```
🧪 Testing Firebase FCM v1 API Setup...

📁 Service Account Path: /path/to/firebase-service-account.json
✅ Service Account file found!
✅ JSON file is valid!
📋 Project ID: jobsahi-app-notifications
📋 Client Email: firebase-adminsdk-xxxxx@jobsahi-app-notifications.iam.gserviceaccount.com
📋 Private Key: Present

🔑 Testing Access Token Generation...
✅ Access Token generated successfully!
✅ Setup looks good! Ready to send notifications.
```

#### Test Notification Send:

```php
// Manual test
require_once 'api/helpers/notification_helper.php';

// Test single student notification
$result = NotificationHelper::notifyShortlisted(
    $student_user_id = 123,
    $job_title = "Frontend Developer",
    $job_id = 456
);

if ($result['success']) {
    echo "✅ Notification sent successfully!";
} else {
    echo "❌ Error: " . $result['message'];
}
```

---

### Step 5: Quick Setup Checklist

Backend setup complete karne ke liye:

- [ ] Firebase Console se Service Account JSON download karo
- [ ] JSON file ko `api/config/firebase-service-account.json` par save karo
- [ ] File permissions check karo (readable by PHP)
- [ ] `.gitignore` mein file add karo (security)
- [ ] `api/test_firebase_v1.php` run karke test karo
- [ ] Automatic triggers verify karo (shortlisted, new job)
- [ ] Manual notification API test karo

---

## 💻 Code Implementation Details

### Code Comments & Documentation

Sabhi code files mein students-only implementation ke liye clear comments add kiye gaye hain:

#### Updated Files:

1. **`api/helpers/notification_helper.php`**
   - File header mein students-only warning
   - Har method ke documentation mein students-only clarification
   - Query comments mein role filtering details

2. **`api/fcm/save_token.php`**
   - File header mein students-only implementation note
   - Authentication section mein clarification

3. **`api/applications/update_application_status.php`**
   - Shortlisted notification trigger par students-only comment

4. **`api/admin/update_job_status.php`**
   - New job notification trigger par students-only comment

5. **`api/applications/schedule_interview.php`**
   - Interview notification par students-only comment

6. **`api/notifications/get-notifications.php`**
   - File header mein students-focused note

7. **`api/notifications/send_notifications.php`**
   - File header mein students-only clarification

8. **`api/notifications/update-notification.php`**
   - File header mein students-focused note

9. **`api/helpers/firebase_helper_v1.php`**
   - File header mein students-only note

#### Comment Format:

Sabhi files mein yeh format use kiya gaya hai:

```php
// ⚠️ IMPORTANT: Notification system is ONLY for STUDENTS
// - Push notifications are sent only to students
// - FCM tokens are stored only for students
// - All notification methods target students only
```

Ya specific methods par:

```php
// ✅ This method sends notification ONLY to students
// ⚠️ Note: Notifications are sent ONLY to students
```

---

## 🔌 API Endpoints

### 1. Get Notifications
**Endpoint**: `GET /api/notifications/get-notifications.php`

**Authentication**: Required (JWT token - all roles)

**Description**: User ki saari notifications fetch karta hai.

**Response**:
```json
{
  "status": true,
  "data": [
    {
      "id": 1,
      "sender_id": 49,
      "sender_role": "admin",
      "message": "System maintenance at 10 PM tonight",
      "created_at": "2025-09-30 16:39:11",
      "is_read": 0
    }
  ],
  "message": ""
}
```

**Frontend Usage**:
```javascript
fetch('/api/notifications/get-notifications.php', {
  method: 'GET',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(res => res.json())
.then(data => {
  if (data.status) {
    // Display notifications
    console.log(data.data);
  }
});
```

---

### 2. Mark Notification as Read
**Endpoint**: `PATCH /api/notifications/update-notification.php?id={notification_id}`

**Authentication**: Required (JWT token - all roles)

**Description**: Notification ko read mark karta hai.

**Query Parameters**:
- `id` (required): Notification ID

**Response**:
```json
{
  "status": true,
  "message": "Notification marked as read successfully"
}
```

**Frontend Usage**:
```javascript
fetch(`/api/notifications/update-notification.php?id=${notificationId}`, {
  method: 'PATCH',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  }
})
.then(res => res.json())
.then(data => {
  if (data.status) {
    // Notification marked as read
    console.log(data.message);
  }
});
```

---

### 3. Send Notification (Admin/Recruiter/Institute)
**Endpoint**: `POST /api/notifications/send_notifications.php`

**Authentication**: Required (JWT token - admin, recruiter, institute only)

**Description**: Manual notification send karta hai.

**Request Body**:
```json
{
  "message": "Your notification message here",
  "type": "general"  // Optional: 'general', 'system', 'reminder', 'alert'
}
```

**Response**:
```json
{
  "status": true,
  "message": "Notification created successfully",
  "data": {
    "user_id": 49,
    "message": "Your notification message here",
    "type": "general",
    "is_read": 0,
    "created_at": "2025-10-01 10:30:00"
  }
}
```

**Frontend Usage**:
```javascript
fetch('/api/notifications/send_notifications.php', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    message: 'Your notification message',
    type: 'general'
  })
})
.then(res => res.json())
.then(data => {
  if (data.status) {
    console.log('Notification sent:', data.message);
  }
});
```

---

### 4. Save FCM Token
**Endpoint**: `POST /api/fcm/save_token.php`

**Authentication**: Required (JWT token - **students only**)

**Description**: Student ka FCM token save/update karta hai push notifications ke liye.

**Note**: Abhi sirf students ke liye available hai. Recruiter/institute/admin ke tokens store nahi hote.

**Code Comments**: File mein clear header comment add kiya gaya hai jo students-only implementation ko document karta hai.

**Request Body**:
```json
{
  "fcm_token": "your_fcm_token_here",
  "device_type": "android",  // Optional: 'android', 'ios', 'web'
  "device_id": "unique_device_id"  // Optional
}
```

**Response**:
```json
{
  "status": true,
  "message": "FCM token saved successfully"
}
```

**Frontend Usage** (React Native / Flutter example):
```javascript
// After getting FCM token from Firebase
const fcmToken = await messaging().getToken();

fetch('/api/fcm/save_token.php', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    fcm_token: fcmToken,
    device_type: 'android', // or 'ios'
    device_id: deviceId
  })
})
.then(res => res.json())
.then(data => {
  if (data.status) {
    console.log('FCM token saved');
  }
});
```

---

### 5. Get Notification Templates
**Endpoint**: `GET /api/notification_templates/get_notification_templates.php`

**Authentication**: Required (JWT token - all roles)

**Description**: Saare notification templates fetch karta hai.

**Response**:
```json
{
  "status": true,
  "message": "Notification templates retrieved successfully",
  "data": [
    {
      "id": 1,
      "name": "Welcome Email",
      "type": "email",
      "subject": "Welcome to JobSahi!",
      "body": "Welcome to JobSahi! We are excited to have you join our community.",
      "created_at": "2025-08-26 14:36:09"
    }
  ],
  "count": 1
}
```

---

### 6. Create/Update Notification Template
**Endpoint**: `POST /api/notification_templates/create_notification_template.php`

**Authentication**: Required (JWT token - admin, recruiter, institute only)

**Description**: New template create karta hai ya existing template update karta hai.

**Request Body (Create)**:
```json
{
  "name": "Job Application Template",
  "type": "push",
  "subject": "Application Received",
  "body": "Your application has been received successfully."
}
```

**Request Body (Update)**:
```json
{
  "id": 1,
  "name": "Updated Template Name",
  "subject": "Updated Subject"
}
```

**Response**:
```json
{
  "status": true,
  "message": "Notification template created successfully",
  "data": {
    "id": 1
  }
}
```

---

## 🔔 Automatic Notification Triggers

System automatically notifications send karta hai yeh events par. **Sabhi notifications sirf students ke liye hain.**

### 1. Job Application Shortlisted
**Trigger**: Jab application status `shortlisted` ho jata hai

**Location**: `api/applications/update_application_status.php`

**Notification Details**:
- **Type**: `shortlisted`
- **Title**: "🎉 Congratulations! You've been shortlisted"
- **Message**: "You have been shortlisted for the position: {job_title}"
- **Data Payload**:
  ```json
  {
    "type": "shortlisted",
    "job_id": "123",
    "job_title": "Frontend Developer"
  }
  ```

**Recipient**: ✅ **Sirf Student** (application owner)

**Implementation**:
```php
// api/applications/update_application_status.php
if ($new_status === 'shortlisted') {
    require_once '../helpers/notification_helper.php';
    NotificationHelper::notifyShortlisted($student_user_id, $job_title, $job_id);
}
```

---

### 2. New Job Posted
**Trigger**: Jab admin job ko `approved` mark karta hai

**Location**: `api/admin/update_job_status.php`

**Notification Details**:
- **Type**: `new_job`
- **Title**: "🆕 New Job Posted!"
- **Message**: "A new job has been posted: {job_title} - {location}"
- **Data Payload**:
  ```json
  {
    "type": "new_job",
    "job_id": "123",
    "job_title": "Frontend Developer",
    "location": "Mumbai"
  }
  ```

**Recipient**: ✅ **Saare active students** (batch processing - 1000 tokens per batch)

**Implementation**:
```php
// api/admin/update_job_status.php
if ($admin_action === 'approved') {
    require_once '../helpers/notification_helper.php';
    NotificationHelper::notifyNewJobPosted($job_title, $job_id, $location);
}
```

**Query**: Sirf students ke tokens fetch hote hain:
```sql
SELECT DISTINCT fcm_token 
FROM fcm_tokens ft
INNER JOIN users u ON ft.user_id = u.id
WHERE u.role = 'student' 
  AND ft.is_active = 1
  AND u.status = 'active'
  AND u.is_verified = 1
```

---

### 3. Interview Scheduled
**Trigger**: Jab recruiter interview schedule karta hai

**Location**: `api/applications/schedule_interview.php`

**Notification Details**:
- **Type**: `shortlisted` (same as shortlisted notification)
- **Recipient**: ✅ **Sirf Student**

---

## 🛠️ Helper Functions

### NotificationHelper Class
**File**: `api/helpers/notification_helper.php`

**Important**: Sabhi methods sirf students ke liye kaam karte hain.

**Code Comments**: File mein clear comments add kiye gaye hain jo students-only implementation ko document karte hain.

#### Available Methods:

1. **notifyShortlisted($student_user_id, $job_title, $job_id)**
   - ✅ **Sirf student** ko shortlisted notification send karta hai
   - FCM token fetch karta hai: `getUserFCMTokens($student_user_id)`
   - Database mein notification save karta hai
   - Returns: `['success' => true/false, 'message' => '...']`

2. **notifyNewJobPosted($job_title, $job_id, $location = '')**
   - ✅ **Saare active students** ko new job notification send karta hai
   - Uses: `getAllStudentFCMTokens()` - sirf students ke tokens
   - Batch processing support (1000 tokens per batch - FCM limit)
   - Database mein saare students ke liye notifications save karta hai
   - Returns: `['success' => true/false, 'message' => '...']`

3. **getUserFCMTokens($user_id)**
   - User ke saare active FCM tokens fetch karta hai
   - **Note**: Abhi sirf students ke tokens store hote hain
   - Returns: Array of FCM tokens

4. **getAllStudentFCMTokens()**
   - ✅ **Sirf active students** ke FCM tokens fetch karta hai
   - Query: `WHERE u.role = 'student' AND ft.is_active = 1 AND u.status = 'active' AND u.is_verified = 1`
   - Returns: Array of FCM tokens (sirf students ke)

### FirebaseHelperV1 Class
**File**: `api/helpers/firebase_helper_v1.php`

FCM v1 API ke liye low-level helper class:

1. **getAccessToken()** (private)
   - Service Account JSON se OAuth2 access token generate karta hai
   - Token caching (1 hour expiry)
   - JWT signing handle karta hai

2. **sendToDevice($fcmToken, $title, $body, $data = [])**
   - Single device ko notification send karta hai

3. **sendToMultipleDevices($tokens, $title, $body, $data = [])**
   - Multiple devices ko notifications send karta hai
   - Batch processing support

---

## 📱 Frontend Integration Guide

### Step 1: FCM Token Registration
App start hone par FCM token register karein:

```javascript
// React Native Example
import messaging from '@react-native-firebase/messaging';

async function registerFCMToken() {
  try {
    // Request permission
    const authStatus = await messaging().requestPermission();
    const enabled =
      authStatus === messaging.AuthorizationStatus.AUTHORIZED ||
      authStatus === messaging.AuthorizationStatus.PROVISIONAL;

    if (enabled) {
      // Get FCM token
      const fcmToken = await messaging().getToken();
      
      // Save to backend
      await fetch('/api/fcm/save_token.php', {
        method: 'POST',
        headers: {
          'Authorization': 'Bearer ' + userToken,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify({
          fcm_token: fcmToken,
          device_type: Platform.OS, // 'android' or 'ios'
          device_id: DeviceInfo.getUniqueId()
        })
      });
    }
  } catch (error) {
    console.error('FCM registration error:', error);
  }
}
```

---

### Step 2: Fetch Notifications
User login hone par notifications fetch karein:

```javascript
async function fetchNotifications() {
  try {
    const response = await fetch('/api/notifications/get-notifications.php', {
      method: 'GET',
      headers: {
        'Authorization': 'Bearer ' + userToken,
        'Content-Type': 'application/json'
      }
    });
    
    const data = await response.json();
    
    if (data.status) {
      // Filter unread notifications
      const unreadCount = data.data.filter(n => n.is_read === 0).length;
      
      // Update UI
      setNotifications(data.data);
      setUnreadCount(unreadCount);
    }
  } catch (error) {
    console.error('Fetch notifications error:', error);
  }
}
```

---

### Step 3: Mark as Read
Notification click par mark as read karein:

```javascript
async function markAsRead(notificationId) {
  try {
    const response = await fetch(
      `/api/notifications/update-notification.php?id=${notificationId}`,
      {
        method: 'PATCH',
        headers: {
          'Authorization': 'Bearer ' + userToken,
          'Content-Type': 'application/json'
        }
      }
    );
    
    const data = await response.json();
    
    if (data.status) {
      // Update local state
      updateNotificationStatus(notificationId, true);
    }
  } catch (error) {
    console.error('Mark as read error:', error);
  }
}
```

---

### Step 4: Handle Push Notifications
Background aur foreground notifications handle karein:

```javascript
// React Native Example
import messaging from '@react-native-firebase/messaging';

// Foreground notifications
messaging().onMessage(async remoteMessage => {
  console.log('Foreground notification:', remoteMessage);
  
  // Show local notification
  showLocalNotification({
    title: remoteMessage.notification.title,
    body: remoteMessage.notification.body,
    data: remoteMessage.data
  });
  
  // Refresh notifications list
  fetchNotifications();
});

// Background notifications
messaging().setBackgroundMessageHandler(async remoteMessage => {
  console.log('Background notification:', remoteMessage);
});

// Notification tap handler
messaging().onNotificationOpenedApp(remoteMessage => {
  console.log('Notification opened:', remoteMessage);
  
  // Navigate based on notification type
  if (remoteMessage.data.type === 'shortlisted') {
    navigation.navigate('JobDetails', { jobId: remoteMessage.data.job_id });
  } else if (remoteMessage.data.type === 'new_job') {
    navigation.navigate('JobDetails', { jobId: remoteMessage.data.job_id });
  }
});
```

---

### Step 5: Notification UI Component Example

```javascript
function NotificationItem({ notification, onPress }) {
  return (
    <TouchableOpacity
      style={[
        styles.notificationItem,
        !notification.is_read && styles.unreadNotification
      ]}
      onPress={() => {
        onPress(notification);
        markAsRead(notification.id);
      }}
    >
      <Text style={styles.message}>{notification.message}</Text>
      <Text style={styles.timestamp}>
        {formatDate(notification.created_at)}
      </Text>
      {!notification.is_read && <View style={styles.unreadDot} />}
    </TouchableOpacity>
  );
}
```

---

## 📊 Notification Types

System mein yeh notification types use hote hain:

1. **shortlisted**: Jab student shortlisted hota hai
2. **new_job**: Jab naya job post hota hai
3. **general**: General notifications
4. **system**: System maintenance/updates
5. **reminder**: Reminder notifications
6. **alert**: Important alerts

---

## 🔐 Security & Permissions

### API Authentication
- Saare endpoints JWT token require karte hain
- Role-based access control:
  - **Get Notifications**: All roles
  - **Mark as Read**: All roles
  - **Send Notifications**: Admin, Recruiter, Institute only
  - **Create Templates**: Admin, Recruiter, Institute only

### FCM Token Security
- FCM tokens user-specific hote hain
- Tokens automatically inactive ho jate hain jab user delete hota hai (CASCADE)
- Device-specific tokens (unique per device)

---

## 📝 Important Notes

### Students Only Implementation

1. **FCM Tokens**: Sirf students ke FCM tokens store hote hain
   - `fcm_tokens` table mein sirf students ke entries hain
   - `getAllStudentFCMTokens()` method sirf students ke tokens fetch karta hai
   - Query: `WHERE u.role = 'student'`
   - **Code Comments**: `api/fcm/save_token.php` mein clear documentation

2. **Push Notifications**: Sirf students ko push notifications bheje jate hain
   - Job shortlisted → Student (code: `api/applications/update_application_status.php`)
   - New job posted → Saare students (code: `api/admin/update_job_status.php`)
   - Interview scheduled → Student (code: `api/applications/schedule_interview.php`)
   - **Code Comments**: Har trigger file mein students-only comments add kiye gaye hain

3. **Database Notifications**: Database mein notifications store hoti hain
   - `notifications` table mein saari notifications save hoti hain
   - `received_role` field se role track hota hai
   - Abhi sirf students ke liye notifications create hoti hain
   - **Code Comments**: Helper methods mein clear documentation

4. **Code Documentation**: 
   - Sabhi relevant files mein students-only comments add kiye gaye hain
   - File headers mein implementation notes
   - Method comments mein role clarifications
   - Query comments mein filtering details

### Technical Notes

1. **Batch Processing**: Agar 1000+ FCM tokens hain, to notifications batches mein send hote hain (FCM limit: 1000 per request)

2. **Database Storage**: Har notification database mein save hoti hai, chahe push notification send ho ya na ho

3. **Read Status**: `is_read` field manually update hota hai jab user notification ko read mark karta hai

4. **FCM Token Refresh**: FCM tokens periodically refresh hote hain, isliye token update API call karein jab bhi token change ho

5. **Service Account Security**: Firebase Service Account JSON file ko `.gitignore` mein add karo (sensitive data)

---

## 🐛 Troubleshooting

### Notifications nahi aa rahi?
1. ✅ **User role check karo**: Sirf students ko notifications milti hain
2. Check karein FCM token properly save hua hai ya nahi (`fcm_tokens` table)
3. Verify karein Firebase Service Account JSON file sahi location par hai
4. Check karein `api/test_firebase_v1.php` test pass ho raha hai
5. Database mein notifications save ho rahi hain ya nahi check karein (`notifications` table)
6. Error logs check karo: `error_log()` messages

### Push notifications kaam nahi kar rahe?
1. ✅ **User student hai ya nahi verify karo**: Sirf students ke tokens store hote hain
2. Device par notification permissions enable hain ya nahi check karein
3. FCM token valid hai ya nahi verify karein
4. Firebase Service Account JSON file accessible hai ya nahi
5. Firebase project configuration check karein (`jobsahi-app-notifications`)
6. Network connectivity check karein
7. OAuth2 access token generate ho raha hai ya nahi check karo

### Backend Setup Issues?
1. **Service Account JSON missing**:
   - Firebase Console se download karo
   - `api/config/firebase-service-account.json` par save karo
   - File permissions check karo (readable by PHP)

2. **Access Token generation fail**:
   - Service Account JSON valid hai ya nahi check karo
   - Private key properly formatted hai ya nahi
   - Error logs check karo

3. **Notifications database mein save nahi ho rahi**:
   - Database connection check karo
   - `notifications` table exists hai ya nahi
   - User role 'student' hai ya nahi verify karo

---

## 📞 Support

Agar koi issue ho ya clarification chahiye, to development team se contact karein.

---

---

## ✅ Summary: Students Only Confirmation

### Current Implementation Status

| Feature | Recipient | Status |
|---------|-----------|--------|
| Job Application Shortlisted | ✅ Student only | ✅ Working |
| New Job Posted | ✅ All Students | ✅ Working |
| Interview Scheduled | ✅ Student only | ✅ Working |
| FCM Token Storage | ✅ Students only | ✅ Working |
| Push Notifications | ✅ Students only | ✅ Working |
| Database Notifications | ✅ Students only | ✅ Working |

### Key Points:
- ✅ **Notifications sirf students ke liye**
- ✅ **FCM tokens sirf students ke store hote hain**
- ✅ **Automatic triggers sirf students ko target karte hain**
- ✅ **App access sirf students ka** (recruiter/institute/admin app access nahi kar sakte)

---

**Last Updated**: October 2025  
**Version**: 1.2  
**Status**: Students Only Implementation  
**Code Comments**: ✅ All code files updated with students-only documentation

