import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('Error fetching user data: $e');
      return null;
    }
  }

  Future<String> getInitialRoute(String uid) async {
    try {
      Map<String, dynamic>? userData = await getUserData(uid);
      if (userData != null && userData['role'] != null) {
        int role = userData['role'] as int;
        if (role == 1) {
          return '/dashboard';
        } else if (role == 2) {
          return '/questionnaires';
        }
      }
      // Default route if role is not set or is invalid
      return '/login';
    } catch (e) {
      print('Error getting initial route: $e');
      return '/login';
    }
  }

  Future<void> saveUserData(
      User user, Map<String, dynamic> additionalData) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'first_name': additionalData['first_name'],
      'last_name': additionalData['last_name'],
      'role': additionalData['role'],
    }, SetOptions(merge: true));
  }

  Future<int> getUserCount() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      return snapshot.size;
    } catch (e) {
      print('Error fetching user count: $e');
      rethrow;
    }
  }

  Future<int> getQuestionnaireCount() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('questionnaires').get();
      return snapshot.size;
    } catch (e) {
      print('Error fetching questionnaire count: $e');
      rethrow;
    }
  }

  getInitialRouteWithParams(String uid) {}
}
