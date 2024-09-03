import 'package:flutter/material.dart';

import '../firebase.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String questionnaireId;
  final String title;

  QuestionnaireScreen({required this.questionnaireId, required this.title});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String? selectedCategory;
  List<String> categories = [];
  List<Map<String, dynamic>> questions = [];
  Map<String, String> selectedOptions = {};
  Map<String, String> comments = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    List<String> loadedCategories =
        await _firebaseService.getCategories(widget.questionnaireId);
    setState(() {
      categories = loadedCategories;
      if (categories.isNotEmpty) {
        selectedCategory = categories.first;
        _loadQuestions();
      }
    });
  }

  Future<void> _loadQuestions() async {
    if (selectedCategory != null) {
      List<Map<String, dynamic>> loadedQuestions = await _firebaseService
          .getQuestions(widget.questionnaireId, selectedCategory!);
      setState(() {
        questions = loadedQuestions;
      });
    }
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'Show Result':
        // Implement show result logic here
        break;
      case 'Report':
        // Implement report logic here
        break;
    }
  }

  void _handleSaveOffline() {
    // Implement logic for saving responses offline
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Responses saved offline')),
    );
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items:
                  categories.map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                  _loadQuestions();
                });
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final questionId = question['id'];
                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question['text'],
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...question['options'].map<Widget>((option) {
                          return RadioListTile<String>(
                            title: Text(option),
                            value: option,
                            groupValue: selectedOptions[questionId],
                            onChanged: (String? value) {
                              setState(() {
                                selectedOptions[questionId] = value!;
                              });
                            },
                          );
                        }).toList(),
                        SizedBox(height: 10),
                        if (selectedOptions[questionId] != null)
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Comment (if applicable)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              setState(() {
                                comments[questionId] = text;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleSaveOffline,
        label: Text('Save Offline'),
        icon: Icon(Icons.save),
      ),
    );
  }
}
