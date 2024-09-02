import 'package:flutter/material.dart';
import 'list_questionnaire.dart';
import 'manage_question.dart';
import 'questionnaire_screen.dart'; // Import the ManageQuestion screen

class ManageCategory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions'),
      ),
      body: ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          String category = categories.keys.elementAt(index);
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(category),
              subtitle: Text(
                  '${categories[category]!.length} questions in this category'),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'Edit':
                      // Implement edit logic here (e.g., rename category)
                      _editCategoryDialog(context, category);
                      break;
                    case 'Delete':
                      // Implement delete logic here
                      _deleteCategory(context, category);
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
              onTap: () {
                // Navigate to the ManageQuestion screen when a category is clicked
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageQuestion(category: category),
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

  void _editCategoryDialog(BuildContext context, String category) {
    String updatedCategory = category;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Category'),
          content: TextField(
            onChanged: (value) {
              updatedCategory = value;
            },
            decoration: InputDecoration(hintText: "Enter New Category Name"),
            controller: TextEditingController(text: category),
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
                if (updatedCategory.isNotEmpty && updatedCategory != category) {
                  // Rename the category
                  List<Question>? questions = categories.remove(category);
                  categories[updatedCategory] = questions!;
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteCategory(BuildContext context, String category) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Category'),
          content: Text('Are you sure you want to delete "$category"?'),
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
                categories.remove(category);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
              onPressed: () {
                if (newCategory.isNotEmpty) {
                  categories[newCategory] = [];
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
