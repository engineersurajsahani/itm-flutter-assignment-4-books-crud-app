// Firebase Configuration and credentials helper
//
// Bhaii jab aapke paas Firebase project ke credentials hon, 
// to aap unhe yahan paste kar sakte hain:
// 
// 1. Go to Firebase Console: https://console.firebase.google.com/
// 2. Select your Project -> Project Settings (gear icon) -> General
// 3. Scroll down to "Your apps" (Web / Android / iOS)
// 4. Copy the config values and paste them below.

class FirebaseConfig {
  /// Firebase Web / REST API Key
  static const String apiKey = "AIzaSyARZGFE3T89rIspVgAyI_K_zoh_cH-MXic";

  /// Firebase Project ID
  static const String projectId = "assignment-4flutter";

  /// Firebase Auth Domain (usually: `project-id.firebaseapp.com`)
  static const String authDomain = "assignment-4flutter.firebaseapp.com";

  /// Firebase Storage Bucket (usually: `project-id.appspot.com`)
  static const String storageBucket = "assignment-4flutter.firebasestorage.app";

  /// Firebase Messaging Sender ID
  static const String messagingSenderId = "525881911";

  /// Firebase App ID
  static const String appId = "1:525881911:web:a47d44c9da62921a59e5b2";

  /// Measurement ID (Optional)
  static const String measurementId = "G-J45V0EQG1Y";

  /// Helper check: Returns true only if actual credentials have been pasted
  static bool get isConfigured {
    return apiKey.isNotEmpty &&
        !apiKey.contains("PASTE_YOUR") &&
        projectId.isNotEmpty &&
        !projectId.contains("PASTE_YOUR");
  }

  /// REST Auth endpoint for Email/Password SignUp
  static String get signUpUrl =>
      "https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey";

  /// REST Auth endpoint for Email/Password SignIn
  static String get signInUrl =>
      "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey";
}
