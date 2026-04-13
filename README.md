Task Manager App (Flutter + Firebase)

A real-time task management application built using Flutter and Firebase Firestore. The app allows users to create tasks, manage subtasks, toggle completion status, and delete tasks with instant cloud synchronization across devices.

 Features
 Core Features
Add new tasks
Mark tasks as complete/incomplete
Delete tasks
Add nested subtasks for each task
Real-time updates using Firebase Firestore
Persistent cloud storage (data survives app restart)

Enhanced Feature 1: Subtask Management System
Each task supports multiple nested subtasks. Users can:

Add subtasks under any task
Mark subtasks as complete/incomplete
Delete individual subtasks
This improves task organization by allowing breakdown of larger tasks into smaller actionable steps.

Enhanced Feature 2: Improved User Experience (UX Polish)
The app includes several UX improvements:

Input validation with SnackBar feedback (prevents empty tasks)
Delete confirmation dialog to prevent accidental deletions
Enhanced empty state UI with icons and guidance text
Loading indicator while fetching Firestore data
These improvements make the app more user-friendly and prevent common user mistakes.

Tech Stack
Flutter (UI framework)
Firebase Firestore (backend database)
Dart (programming language)
⚙️ Setup Instructions
1. Clone Repository
git clone <your-repo-link>
cd cw03

3. Install Dependencies
flutter pub get

4. Configure Firebase
Create a Firebase project at https://console.firebase.google.com
Enable Firestore Database
Run FlutterFire CLI:
flutterfire configure

5. Run the App
flutter run

Firestore Structure
tasks (collection)
 ├── documentId
      ├── title: string
      ├── isCompleted: bool
      ├── createdAt: timestamp
      ├── subtasks: array of maps

Example subtask:

{
  "title": "Example subtask",
  "isCompleted": false
}
Known Limitations
No user authentication (all tasks are shared in one database)
No offline-first conflict resolution for simultaneous edits
No search or filtering functionality yet

Built as a learning project to demonstrate Flutter + Firebase integration, real-time updates
