import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inkspire/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  // NEW: Reset password by sending a password reset email
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

  // Sign out (simplified: only Firebase Auth)
  Future<void> signOut() async {
    await _auth.signOut();
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
