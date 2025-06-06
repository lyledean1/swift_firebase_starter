# iOS Firebase Starter App

This is a ready-to-use starter template for building iOS applications with Firebase integration. It includes authentication, Firestore database connections, and basic UI components to help you get started quickly.

<p align="center">
 <img src="https://github.com/user-attachments/assets/18c807f9-cc60-4bf8-8466-e7e3cb47f393" width="200">
 <img src="https://github.com/user-attachments/assets/64b35e1c-1025-4f98-99e1-88a4fdc84aef" width="200">
 <img src="https://github.com/user-attachments/assets/90c614bc-c145-415c-b337-ed58c3c42af8" width="200">
</p>

## Features

- Firebase Authentication (sign up, sign in, sign out for Google + Apple Sign In)
- Firestore database integration
- Profile management
- SwiftUI-based user interface
- Example views for common functionality

## Getting Started

### Prerequisites

- Xcode 13.0 or later
- CocoaPods (if needed for additional dependencies)
- A Firebase account
- iOS 15.0+ deployment target

### Setup Instructions

1. **Clone this repository**
   ```
   git clone https://github.com/lyledean1/swift_firebase_starter.git
   cd swift_firebase_starter
   ```

2. **Create a Firebase project**
   - Go to the [Firebase Console](https://console.firebase.google.com/)
   - Click "Add project" and follow the setup steps
   - Register your app in Firebase by clicking "Add app" and selecting iOS
   
3. **Set up your Bundle ID**
   - You MUST change the bundle identifier in Xcode to match the one you registered in Firebase
   - In Xcode, select the project in the Project Navigator
   - Select the main target under "TARGETS"
   - In the "General" tab, update the "Bundle Identifier" to match exactly what you registered in Firebase
   <img width="658" alt="Screenshot 2025-05-28 at 21 06 41" src="https://github.com/user-attachments/assets/45d9d30e-4ac0-48b2-b8ed-d9609c951ee7" />


4. **Download and add the GoogleService-Info.plist**
   - Download the `GoogleService-Info.plist` file from your Firebase project
   - Drag and drop it into your Xcode project
   - Make sure "Copy items if needed" is checked
   - Add it to your main target
<img width="267" alt="Screenshot 2025-05-28 at 21 02 28" src="https://github.com/user-attachments/assets/10f1d769-653b-40d5-9f24-16eb8491a615" />


5. **Configure Firebase in the app**
   - The app is already set up to initialize Firebase in the `firebase_starterApp.swift` file
   - Make sure the bundle identifier in Xcode matches the one in your Firebase console exactly

6. **Run the app**
   - Select a simulator or connected device
   - Press the Run button (▶) in Xcode

## Common Issues and Solutions

- **Authentication fails**: Make sure your Firebase project has the authentication methods enabled that you want to use
- **App crashes on startup**: Check that your `GoogleService-Info.plist` is correctly added and that the bundle identifier matches
- **Firebase connection issues**: Verify your internet connection and that the Firebase project is properly set up

## Customizing the App

1. **Change the app name**:
   - Update the display name in Xcode under the "General" tab
   - Update references in code as needed

2. **Add more Firebase services**:
   - Follow the Firebase documentation to add additional services like Storage, Functions, etc.
   - Update the Firebase dependencies in your project as needed

