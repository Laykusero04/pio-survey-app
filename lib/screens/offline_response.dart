import 'package:flutter/material.dart';

import '../components/drawer.dart';

class OfflineResponseScreen extends StatelessWidget {
  final List<OfflineQuestionnaire> offlineQuestionnaires = [
    OfflineQuestionnaire(
      title: "Customer Satisfaction Survey",
      dateSaved: DateTime.now().subtract(Duration(days: 1)),
      respondentCount: 5,
      inputBy: "John Doe",
    ),
    OfflineQuestionnaire(
      title: "Employee Feedback",
      dateSaved: DateTime.now().subtract(Duration(days: 2)),
      respondentCount: 10,
      inputBy: "Jane Smith",
    ),
  ];

  void _handleMenuSelection(String value, BuildContext context) {
    switch (value) {
      case 'Save Online':
        // Implement save online logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data saved all data online')),
        );
        break;
      case 'Delete':
        // Implement delete logic here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Data deleted')),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Offline Responses'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: offlineQuestionnaires.length,
        itemBuilder: (context, index) {
          final questionnaire = offlineQuestionnaires[index];

          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(questionnaire.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saved on: ${questionnaire.dateSaved.toLocal()}'),
                  Text('Respondents: ${questionnaire.respondentCount}'),
                  Text('Input by: ${questionnaire.inputBy}'),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) => _handleMenuSelection(value, context),
                itemBuilder: (BuildContext context) {
                  return {'Save Online', 'Delete'}.map((String choice) {
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
    );
  }
}

class OfflineQuestionnaire {
  final String title;
  final DateTime dateSaved;
  final int respondentCount;
  final String inputBy;

  OfflineQuestionnaire({
    required this.title,
    required this.dateSaved,
    required this.respondentCount,
    required this.inputBy,
  });
}
