import 'package:flutter/material.dart';
import 'questionnaire_screen.dart'; // Import the QuestionnaireScreen

import '../components/drawer.dart';

class ListQuestionnaireScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Questionnaire'),
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
                    case 'Show Results':
                      // Implement show results logic here
                      break;
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
                  return {'Show Results', 'Delete', 'Edit', 'Report'}
                      .map((String choice) {
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
                    builder: (context) => QuestionnaireScreen(
                      title: questionnaires[index].title,
                      categories: {
                        questionnaires[index].category:
                            categories[questionnaires[index].category]!,
                      },
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Dummy questionnaire data
class Questionnaire {
  final String title;
  final String createdBy;
  final String dateCreated;
  final String category;

  Questionnaire({
    required this.title,
    required this.createdBy,
    required this.dateCreated,
    required this.category,
  });
}

List<Questionnaire> questionnaires = [
  Questionnaire(
      title: 'Customer Satisfaction Survey',
      createdBy: 'Admin',
      dateCreated: '2024-09-01',
      category: 'Customer Satisfaction'),
  Questionnaire(
      title: 'Product Feedbacks',
      createdBy: 'User1',
      dateCreated: '2024-08-30',
      category: 'Product Feedback'),
  // Add more questionnaires here
];

final Map<String, List<Question>> categories = {
  'Customer Satisfaction': [
    Question(
      text: 'How satisfied are you with our service?',
      options: ['Very Satisfied', 'Satisfied', 'Neutral', 'Dissatisfied'],
    ),
    Question(
      text: 'Would you recommend us to others?',
      options: ['Definitely', 'Probably', 'Not Sure', 'Probably Not'],
    ),
  ],
  'Product Feedback': [
    Question(
      text: 'How would you rate the product quality?',
      options: ['Excellent', 'Good', 'Average', 'Poor'],
    ),
    Question(
      text: 'How likely are you to purchase this product again?',
      options: ['Very Likely', 'Likely', 'Unlikely', 'Very Unlikely'],
    ),
  ],
};
