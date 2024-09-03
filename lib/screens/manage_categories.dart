import 'package:flutter/material.dart';
import '../firebase.dart';
import 'manage_question.dart';

class ManageCategory extends StatefulWidget {
  final String questionnaireId;

  ManageCategory({required this.questionnaireId, required String title});

  @override
  _ManageCategoryState createState() => _ManageCategoryState();
}

class _ManageCategoryState extends State<ManageCategory> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> categories = [];

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
    });
  }

  void _addCategoryDialog(BuildContext context) {
    String newCategory = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add New Category'),
          content: TextField(
            onChanged: (value) {
              newCategory = value;
            },
            decoration: InputDecoration(hintText: "Enter Category Name"),
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
                if (newCategory.isNotEmpty) {
                  await _firebaseService.addCategory(
                      widget.questionnaireId, newCategory);
                  Navigator.of(context).pop();
                  _loadCategories();
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
        title: Text('Manage Categories'),
      ),
      body: categories.isEmpty
          ? Center(child: Text('No categories available'))
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(categories[index]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageQuestion(
                            questionnaireId: widget.questionnaireId,
                            category: categories[index],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addCategoryDialog(context);
        },
        child: Icon(Icons.add),
        tooltip: 'Add Category',
      ),
    );
  }
}
