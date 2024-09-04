import 'package:flutter/material.dart';
import '../firebase.dart';
import 'result_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String questionnaireId;
  final String title;

  QuestionnaireScreen({required this.questionnaireId, required this.title});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Map<String, List<Map<String, dynamic>>> categorizedQuestions = {};
  Map<String, String> selectedOptions = {};
  Map<String, String> comments = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllQuestions();
  }

  Future<void> _loadAllQuestions() async {
    try {
      Map<String, List<Map<String, dynamic>>> loadedQuestions =
          await _firebaseService
              .getAllQuestionsGroupedByCategory(widget.questionnaireId);
      setState(() {
        categorizedQuestions = loadedQuestions;
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

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show Result':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              questionnaireId: widget.questionnaireId,
              title: widget.title,
            ),
          ),
        );
        break;
      case 'Report':
        // TODO: Implement report logic
        break;
    }
  }

  Future<void> _handleSaveResponses() async {
    try {
      for (var category in categorizedQuestions.keys) {
        for (var question in categorizedQuestions[category]!) {
          String questionId = question['id'];
          String? response = selectedOptions[questionId];
          String? comment = comments[questionId];

          if (response != null) {
            await _firebaseService.saveResponse(
                widget.questionnaireId, questionId, response, comment);
          }
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Responses saved successfully')),
      );
    } catch (e) {
      print('Error saving responses: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save responses. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuSelection,
            itemBuilder: (BuildContext context) {
              return {'Show Result', 'Report'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: categorizedQuestions.entries.map((entry) {
                    return _buildCategorySection(entry.key, entry.value);
                  }).toList(),
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleSaveResponses,
        label: Text('Save All Responses'),
        icon: Icon(Icons.save),
      ),
    );
  }

  Widget _buildCategorySection(
      String category, List<Map<String, dynamic>> questions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Text(
            category,
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ...questions.map((question) => _buildQuestionCard(question)).toList(),
        Divider(thickness: 2),
      ],
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final questionId = question['id'];

    return Card(
      elevation: 4,
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ...(question['options'] as List<dynamic>)
                .map<Widget>((option) => _buildOptionTile(questionId, option)),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Comment (if applicable)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onChanged: (text) {
                setState(() {
                  comments[questionId] = text;
                });
              },
              controller: TextEditingController(text: comments[questionId]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(String questionId, String option) {
    bool isSelected = selectedOptions[questionId] == option;
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: RadioListTile<String>(
        title: Text(option),
        value: option,
        groupValue: selectedOptions[questionId],
        onChanged: (String? value) {
          setState(() {
            selectedOptions[questionId] = value!;
          });
        },
        activeColor: Colors.blue,
      ),
    );
  }
}
