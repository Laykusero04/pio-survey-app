import 'package:flutter/material.dart';
import '../firebase.dart';
import 'manage_categories.dart';
import 'manage_question_details.dart';
import 'questionnaire_screen.dart';
import '../components/drawer.dart';

class ListQuestionnaireScreen extends StatefulWidget {
  @override
  _ListQuestionnaireScreenState createState() =>
      _ListQuestionnaireScreenState();
}

class _ListQuestionnaireScreenState extends State<ListQuestionnaireScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  List<Map<String, dynamic>> questionnaires = [];

  @override
  void initState() {
    super.initState();
    _loadQuestionnaires();
  }

  Future<void> _loadQuestionnaires() async {
    List<Map<String, dynamic>> loadedQuestionnaires =
        await _firebaseService.getQuestionnaires();
    setState(() {
      questionnaires = loadedQuestionnaires;
    });
  }

  void _addQuestionnaire() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newTitle = '';
        return AlertDialog(
          title: Text('Add New Questionnaire'),
          content: TextField(
            onChanged: (value) {
              newTitle = value;
            },
            decoration: InputDecoration(hintText: "Enter Questionnaire Title"),
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
                if (newTitle.isNotEmpty) {
                  await _firebaseService.addQuestionnaire(newTitle);
                  Navigator.of(context).pop();
                  _loadQuestionnaires();
                }
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
        title: Text('Questionnaires'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: questionnaires.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(questionnaires[index]['title']),
              subtitle: Text(
                'Created at: ${questionnaires[index]['createdAt']?.toDate().toString() ?? 'N/A'}',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Manage Questionnaire':
                      // Navigate to the ManageCategory screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCategory(
                            questionnaireId:
                                questionnaires[index]['id'] as String,
                            title: '',
                          ),
                        ),
                      );
                      break;

                    case 'Show Results':
                      break;

                    case 'Delete':
                      break;

                    case 'Edit':
                      break;

                    case 'Report':
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {
                    'Manage Questionnaire',
                    'Show Results',
                    'Delete',
                    'Edit',
                    'Report'
                  }.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.more_vert),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ResearcherDataScreen(
                      questionnaireId: questionnaires[index]['id'] as String,
                      category: questionnaires[index]['catgory'] as String,

                      // Error
                      // Error
                      // Error
                      // Error
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addQuestionnaire,
        child: Icon(Icons.add),
        tooltip: 'Add Questionnaire',
      ),
    );
  }
}
