import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;

  firebase_auth.FirebaseAuth get auth => _auth;

  // Questionnaires
  Future<List<Map<String, dynamic>>> getQuestionnaires() async {
    QuerySnapshot snapshot =
        await _firestore.collection('questionnaires').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> addQuestionnaire(String title) async {
    firebase_auth.User? currentUser = _auth.currentUser;
    await _firestore.collection('questionnaires').add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUser?.email ?? 'Unknown',
      'categories': [],
    });
  }

  // Categories
  Future<List<String>> getCategories(String questionnaireId) async {
    DocumentSnapshot doc = await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .get();
    if (!doc.exists) return [];
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return List<String>.from(data['categories'] ?? []);
  }

  Future<void> addCategory(String questionnaireId, String category) async {
    await _firestore.collection('questionnaires').doc(questionnaireId).update({
      'categories': FieldValue.arrayUnion([category]),
    });
  }

  // Questions
  Future<List<Map<String, dynamic>>> getQuestions(
      String questionnaireId, String category) async {
    QuerySnapshot snapshot = await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('questions')
        .where('category', isEqualTo: category)
        .get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> addQuestion(String questionnaireId, String category, String text,
      List<String> options) async {
    await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('questions')
        .add({
      'category': category,
      'text': text,
      'options': options,
    });
  }

  Future<void> updateQuestion(String questionnaireId, String questionId,
      String text, List<String> options) async {
    await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('questions')
        .doc(questionId)
        .update({
      'text': text,
      'options': options,
    });
  }

  Future<void> deleteQuestion(String questionnaireId, String questionId) async {
    await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('questions')
        .doc(questionId)
        .delete();
  }

  Future<Map<String, dynamic>> getQuestionDetails(
      String questionnaireId, String questionId) async {
    DocumentSnapshot snapshot = await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('questions')
        .doc(questionId)
        .get();

    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      data['id'] = snapshot.id;
      return data;
    } else {
      throw Exception('Question not found');
    }
  }

  Future<void> saveResponse(String questionnaireId, String questionId,
      String response, String? comment) async {
    await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('responses')
        .add({
      'questionId': questionId,
      'response': response,
      'comment': comment,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> getResponses(
      String questionnaireId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('questionnaires')
        .doc(questionnaireId)
        .collection('responses')
        .get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<Map<String, List<Map<String, dynamic>>>>
      getAllQuestionsGroupedByCategory(String questionnaireId) async {
    Map<String, List<Map<String, dynamic>>> result = {};

    // Fetch all categories
    List<String> categories = await getCategories(questionnaireId);

    // Fetch questions for each category
    for (String category in categories) {
      List<Map<String, dynamic>> questions =
          await getQuestions(questionnaireId, category);
      result[category] = questions;
    }

    return result;
  }
}
