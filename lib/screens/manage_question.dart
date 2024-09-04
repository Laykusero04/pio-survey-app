import 'package:flutter/material.dart';
import '../firebase.dart';

class ManageQuestion extends StatefulWidget {
  final String questionnaireId;
  final String category;

  ManageQuestion({required this.questionnaireId, required this.category});

  @override
  _ManageQuestionState createState() => _ManageQuestionState();
}

class _ManageQuestionState extends State<ManageQuestion> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> questions = [];
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _loadQuestions();
  }

  @override
  void dispose() {
    _isMounted = false;
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    if (!_isMounted) return;
    try {
      List<Map<String, dynamic>> loadedQuestions = await _firebaseService
          .getQuestions(widget.questionnaireId, widget.category);
      if (_isMounted) {
        setState(() {
          questions = loadedQuestions;
        });
      }
    } catch (e) {
      print('Error loading questions: $e');
    }
  }

  void _addQuestionDialog(BuildContext context) {
    String newQuestionText = '';
    List<String> options = ['', ''];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      onChanged: (value) {
                        newQuestionText = value;
                      },
                      decoration: InputDecoration(hintText: "Enter Question"),
                    ),
                    SizedBox(height: 10),
                    ...options.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return TextField(
                        onChanged: (value) {
                          options[idx] = value;
                        },
                        decoration:
                            InputDecoration(hintText: "Option ${idx + 1}"),
                      );
                    }).toList(),
                    ElevatedButton(
                      child: Text('Add Option'),
                      onPressed: () {
                        setState(() {
                          options.add('');
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (newQuestionText.isNotEmpty &&
                        options.every((option) => option.isNotEmpty)) {
                      await _firebaseService.addQuestion(widget.questionnaireId,
                          widget.category, newQuestionText, options);
                      Navigator.of(context).pop();
                      _loadQuestions();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _editQuestionDialog(
      BuildContext context, Map<String, dynamic> question) {
    String updatedQuestionText = question['text'];
    List<String> updatedOptions = List<String>.from(question['options']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Question'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller:
                          TextEditingController(text: updatedQuestionText),
                      onChanged: (value) {
                        updatedQuestionText = value;
                      },
                      decoration: InputDecoration(hintText: "Enter Question"),
                    ),
                    SizedBox(height: 10),
                    ...updatedOptions.asMap().entries.map((entry) {
                      int idx = entry.key;
                      return TextField(
                        controller: TextEditingController(text: entry.value),
                        onChanged: (value) {
                          updatedOptions[idx] = value;
                        },
                        decoration:
                            InputDecoration(hintText: "Option ${idx + 1}"),
                      );
                    }).toList(),
                    ElevatedButton(
                      child: Text('Add Option'),
                      onPressed: () {
                        setState(() {
                          updatedOptions.add('');
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () async {
                    if (updatedQuestionText.isNotEmpty &&
                        updatedOptions.every((option) => option.isNotEmpty)) {
                      await _firebaseService.updateQuestion(
                          widget.questionnaireId,
                          question['id'],
                          updatedQuestionText,
                          updatedOptions);
                      Navigator.of(context).pop();
                      _loadQuestions();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteQuestion(BuildContext context, String questionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Question'),
          content: Text('Are you sure you want to delete this question?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                await _firebaseService.deleteQuestion(
                    widget.questionnaireId, questionId);
                Navigator.of(context).pop();
                _loadQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions - ${widget.category}'),
      ),
      body: questions.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(questions[index]['text']),
                    subtitle: Text(
                        'Options: ${questions[index]['options'].join(", ")}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'Edit':
                            _editQuestionDialog(context, questions[index]);
                            break;
                          case 'Delete':
                            _deleteQuestion(context, questions[index]['id']);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) {
                        return {'Edit', 'Delete'}.map((String choice) {
                          return PopupMenuItem<String>(
                            value: choice,
                            child: Text(choice),
                          );
                        }).toList();
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addQuestionDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Question',
      ),
    );
  }
}
