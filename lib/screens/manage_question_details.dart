import 'package:flutter/material.dart';
import '../firebase.dart';

class ResearcherDataScreen extends StatefulWidget {
  final String questionnaireId;
  final String category;

  ResearcherDataScreen({required this.questionnaireId, required this.category});

  @override
  _ResearcherDataScreenState createState() => _ResearcherDataScreenState();
}

class _ResearcherDataScreenState extends State<ResearcherDataScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    try {
      List<Map<String, dynamic>> loadedQuestions = await _firebaseService
          .getQuestions(widget.questionnaireId, widget.category);
      setState(() {
        questions = loadedQuestions;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading questions: $e');
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load questions. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questions - ${widget.category}'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadQuestions,
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : questions.isEmpty
              ? Center(child: Text('No questions available.'))
              : ListView.builder(
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    return _buildQuestionCard(questions[index]);
                  },
                ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: EdgeInsets.all(10),
      child: ExpansionTile(
        title: Text(question['text']),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Category: ${question['category']}'),
                SizedBox(height: 8),
                Text('Options:'),
                ...(question['options'] as List<dynamic>)
                    .map((option) => Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Text('• $option'),
                        )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
