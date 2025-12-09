import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:inkspire/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Stream to listen to auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Register with email and password, then save profile to Firestore
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String firstname,
    required String othername,
  }) async {
    try {
      // Create user with Firebase Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Create UserModel
        UserModel userModel = UserModel(
          id: firebaseUser.uid,
          firstname: firstname,
          othername: othername,
          email: email,
          profilePicture: null, // No profile picture on registration
        );

        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(userModel.toJson());

        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., weak-password, email-already-in-use)
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Registration Error: $e');
      rethrow;
    }
  }

  // Sign in with email and password, then fetch profile from Firestore
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? firebaseUser = result.user;
      if (firebaseUser != null) {
        // Fetch user profile from Firestore
        UserModel? userModel = await getUserModel(firebaseUser.uid);
        if (userModel == null) {
          // If no profile exists (edge case), throw error or handle gracefully
          throw Exception('User profile not found. Please register first.');
        }
        return userModel;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., user-not-found, wrong-password)
      print('Firebase Auth Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  // Reset password by sending a password reset email
  Future<void> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      // Handle specific errors (e.g., user-not-found, invalid-email)
      print('Password Reset Error: ${e.message}');
      rethrow;
    } catch (e) {
      print('Unexpected Error: $e');
      rethrow;
    }
  }

  // Upload profile picture and update user profile
  Future<String?> uploadProfilePicture(File imageFile, String userId) async {
    try {
      // Create a unique path for the profile picture
      final String path = 'profile_pictures/$userId.jpg';
      final ref = _storage.ref().child(path);

      // Upload the file
      await ref.putFile(imageFile);

      // Get the download URL
      final downloadUrl = await ref.getDownloadURL();

      // Update user document in Firestore
      await _firestore.collection('users').doc(userId).update({
        'profilePicture': downloadUrl,
      });

      return downloadUrl;
    } catch (e) {
      print('Error uploading profile picture: $e');
      rethrow;
    }
  }

  // Update profile picture URL in Firestore
  Future<void> updateProfilePicture(String userId, String pictureUrl) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profilePicture': pictureUrl,
      });
    } catch (e) {
      print('Error updating profile picture: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error signing out: $e');
      rethrow;
    }
  }

  // Get user model from Firestore
  Future<UserModel?> getUserModel(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }
}
