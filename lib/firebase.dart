import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Questionnaires
  Future<List<Map<String, dynamic>>> getQuestionnaires() async {
    QuerySnapshot snapshot =
        await _firestore.collection('questionnaires').get();
    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id; // Add the document ID to the map
      return data;
    }).toList();
  }

  Future<void> addQuestionnaire(String title) async {
    await _firestore.collection('questionnaires').add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Categories
  Future<List<String>> getCategories(String questionnaireId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('questionnaires')
          .doc(questionnaireId)
          .get();

      if (!doc.exists) {
        print("Document does not exist");
        return [];
      }

      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

      if (!data.containsKey('categories')) {
        print("Categories field does not exist in the document");
        return [];
      }

      var categories = data['categories'];
      if (categories is List) {
        return List<String>.from(categories);
      } else {
        print("Categories field is not a List");
        return [];
      }
    } catch (e) {
      print("Error fetching categories: $e");
      return [];
    }
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
    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
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

  static saveResponse(String title, Map<String, String> selectedOptions) {}
}
