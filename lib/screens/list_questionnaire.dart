import 'package:flutter/material.dart';
import '../components/role_based_popup_menu.dart';
import '../firebase.dart';
import 'package:intl/intl.dart';
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
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Created at: ${questionnaires[index]['createdAt'] != null ? DateFormat('yyyy-MM-dd HH:mm').format(questionnaires[index]['createdAt'].toDate()) : 'Unknown'}',
                  ),
                  Text(
                    'Created by: ${questionnaires[index]['createdBy'] ?? 'Unknown'}',
                  ),
                ],
              ),
              trailing: RoleBasedPopupMenu(
                questionnaire: questionnaires[index],
                refreshList: _loadQuestionnaires,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => QuestionnaireScreen(
                      questionnaireId: questionnaires[index]['id'],
                      title: questionnaires[index]['title'],
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
