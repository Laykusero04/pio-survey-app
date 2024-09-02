import 'package:flutter/material.dart';

import 'list_questionnaire.dart';
import 'questionnaire_screen.dart';

class ManageQuestion extends StatefulWidget {
  final String category;

  ManageQuestion({required this.category});

  @override
  _ManageQuestionState createState() => _ManageQuestionState();
}

class _ManageQuestionState extends State<ManageQuestion> {
  List<Question> questions = [];
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    questions = categories[widget.category]!;
    _controllers = List.generate(
        questions.length * (1 + questions[0].options.length),
        (_) => TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions - ${widget.category}'),
      ),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(questions[index].text),
              subtitle: Text('Options: ${questions[index].options.join(", ")}'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Edit':
                      _editQuestionDialog(context, index);
                      break;
                    case 'Delete':
                      _deleteQuestion(context, index);
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
                icon: Icon(Icons.more_vert),
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

  void _addQuestionDialog(BuildContext context) {
    String newQuestionText = '';
    int optionCount = 2; // Default number of options
    List<String> options = List.filled(optionCount, '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add New Question'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      newQuestionText = value;
                    },
                    decoration: InputDecoration(hintText: "Enter Question"),
                  ),
                  SizedBox(height: 10),
                  Text('Number of Options:'),
                  DropdownButton<int>(
                    value: optionCount,
                    onChanged: (int? newValue) {
                      setState(() {
                        optionCount = newValue!;
                        options = List.filled(optionCount, '');
                      });
                    },
                    items: List.generate(10, (index) => index + 2)
                        .map((int value) {
                      return DropdownMenuItem<int>(
                        value: value,
                        child: Text(value.toString()),
                      );
                    }).toList(),
                  ),
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
                ],
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
                  onPressed: () {
                    if (newQuestionText.isNotEmpty &&
                        options.every((option) => option.isNotEmpty)) {
                      setState(() {
                        questions.add(
                            Question(text: newQuestionText, options: options));
                        categories[widget.category] = questions;
                      });
                      Navigator.of(context).pop();
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

  void _editQuestionDialog(BuildContext context, int index) {
    String updatedQuestionText = questions[index].text;
    List<String> updatedOptions = List.from(questions[index].options);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit Question'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _controllers[index],
                    onChanged: (value) {
                      updatedQuestionText = value;
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Question",
                    ),
                    autofocus: true,
                  ),
                  SizedBox(height: 10),
                  ...updatedOptions.asMap().entries.map((entry) {
                    int idx = entry.key;
                    return TextField(
                      controller: _controllers[index + 1 + idx],
                      onChanged: (value) {
                        updatedOptions[idx] = value;
                      },
                      decoration: InputDecoration(
                        hintText: "Option ${idx + 1}",
                      ),
                    );
                  }).toList(),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    // Reset the TextEditingController values to their original state
                    _controllers[index].text = questions[index].text;
                    for (int i = 0; i < questions[index].options.length; i++) {
                      _controllers[index + 1 + i].text =
                          questions[index].options[i];
                    }
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('Save'),
                  onPressed: () {
                    if (updatedQuestionText.isNotEmpty &&
                        updatedOptions.every((option) => option.isNotEmpty)) {
                      setState(() {
                        questions[index] = Question(
                            text: updatedQuestionText, options: updatedOptions);
                        categories[widget.category] = questions;
                      });
                      Navigator.of(context).pop();
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

  void _deleteQuestion(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Question'),
          content: Text(
              'Are you sure you want to delete this question: "${questions[index].text}"?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () {
                setState(() {
                  questions.removeAt(index);
                  categories[widget.category] = questions;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
