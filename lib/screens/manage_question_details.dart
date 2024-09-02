import 'package:flutter/material.dart';

import 'list_questionnaire.dart';
import 'questionnaire_screen.dart';

class ManageQuestionDetails extends StatefulWidget {
  final String category;

  ManageQuestionDetails({required this.category});

  @override
  _ManageQuestionDetailsState createState() => _ManageQuestionDetailsState();
}

class _ManageQuestionDetailsState extends State<ManageQuestionDetails> {
  List<String> options = [];
  String questionText = '';

  void _addOption() {
    setState(() {
      options.add('');
    });
  }

  void _removeOption(int index) {
    setState(() {
      options.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions for ${widget.category}'),
      ),
      body: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                questionText = value;
              },
              decoration: InputDecoration(
                labelText: 'Question',
                hintText: 'Enter your question here',
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: TextField(
                      onChanged: (value) {
                        options[index] = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}',
                        hintText: 'Enter option text',
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.remove_circle_outline),
                      onPressed: () {
                        _removeOption(index);
                      },
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _addOption,
                  icon: Icon(Icons.add),
                  label: Text('Add Option'),
                ),
                SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    if (questionText.isNotEmpty && options.isNotEmpty) {
                      // Save the question with options here
                      categories[widget.category]!.add(
                        Question(text: questionText, options: options),
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  icon: Icon(Icons.save),
                  label: Text('Save Question'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
