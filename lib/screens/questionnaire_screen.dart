import 'package:flutter/material.dart';

class QuestionnaireScreen extends StatefulWidget {
  final String title;
  final Map<String, List<Question>> categories;

  QuestionnaireScreen({required this.title, required this.categories});

  @override
  _QuestionnaireScreenState createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  String? selectedCategory;
  String? selectedOption;
  final Map<String, String> comments = {}; // Store comments for each question

  @override
  void initState() {
    super.initState();
    selectedCategory =
        widget.categories.keys.first; // Default to the first category
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

  void _handleNext() {
    // Implement logic for the "Next" button here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Next button pressed')),
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
            icon: Icon(Icons.more_vert),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Category',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              value: selectedCategory,
              items: widget.categories.keys
                  .map<DropdownMenuItem<String>>((String category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedCategory = newValue;
                  selectedOption =
                      null; // Reset selected option when category changes
                });
              },
            ),
          ),
        ),
      ),
      body: selectedCategory == null
          ? Center(child: Text('Please select a category'))
          : ListView.builder(
              itemCount: widget.categories[selectedCategory]!.length,
              itemBuilder: (context, index) {
                final question = widget.categories[selectedCategory]![index];
                final questionKey = 'question_$index';

                return Card(
                  margin: EdgeInsets.all(10),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.text,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Column(
                          children: question.options.map((option) {
                            return RadioListTile<String>(
                              title: Text(option),
                              value: option,
                              groupValue: selectedOption,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedOption = value;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        SizedBox(height: 10),
                        if (selectedOption !=
                            null) // Only show comment field if an option is selected
                          TextField(
                            decoration: InputDecoration(
                              labelText: 'Comment (if applicable)',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (text) {
                              setState(() {
                                comments[questionKey] =
                                    text; // Store comment for the question
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: Container(
        width: 200.0,
        height: 56.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue, // Background color
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.0),
            ),
          ),
          onPressed: _handleNext,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.navigate_next, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Save Offline',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Question {
  final String text;
  final List<String> options;

  Question({required this.text, required this.options});
}
