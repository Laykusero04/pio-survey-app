import 'package:flutter/material.dart';
import 'list_questionnaire.dart';
import 'manage_categories.dart';
import 'questionnaire_screen.dart'; // Import the QuestionnaireScreen
import '../components/drawer.dart';

class ManageQuestionnaire extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questionnaire'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: questionnaires.length,
        itemBuilder: (context, index) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(questionnaires[index].title),
              subtitle: Text(
                'Created by: ${questionnaires[index].createdBy}\nDate: ${questionnaires[index].dateCreated}\nCategory: 3\nQuestion: 20',
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Delete':
                      // Implement delete logic here
                      break;
                    case 'Edit':
                      // Implement edit logic here
                      break;
                    case 'Report':
                      // Implement report logic here
                      break;
                  }
                },
                itemBuilder: (BuildContext context) {
                  return {'Delete', 'Edit', 'Report'}.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
                icon: Icon(Icons.more_vert),
              ),
              onTap: () {
                // Navigate to QuestionnaireScreen when a tile is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageCategory(),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addQuestionnaireDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Questionnaire',
      ),
    );
  }

  void _addQuestionnaireDialog(BuildContext context) {
    String newTitle = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
              onPressed: () {
                if (newTitle.isNotEmpty) {
                  // Add logic to save the new title
                  questionnaires.add(Questionnaire(
                    title: newTitle,
                    createdBy: 'Admin', // This could be dynamic
                    dateCreated:
                        DateTime.now().toString(), // Format date as needed
                    category: 'Uncategorized', // Default or select from a list
                  ));
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}
