import 'package:flutter/material.dart';

import '../components/drawer.dart';

class ManageUserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
      ),
      drawer: AppDrawer(),
      body: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(users[index].name),
            subtitle: Text('${users[index].role} | ${users[index].email}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddUserDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddUserDialog(BuildContext context) {
    String name = '';
    String role = 'User'; // Default value
    String email = '';
    String password = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  name = value;
                },
                decoration: InputDecoration(labelText: 'Name'),
              ),
              DropdownButtonFormField<String>(
                value: role,
                items: <String>['Admin', 'User']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  role = newValue!;
                },
                decoration: InputDecoration(labelText: 'Role'),
              ),
              TextField(
                onChanged: (value) {
                  email = value;
                },
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                onChanged: (value) {
                  password = value;
                },
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Add user logic with name, role, email, and password
                Navigator.of(context).pop();
              },
              child: Text('Add User'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}

// Dummy user data
class User {
  final String name;
  final String role;
  final String email;

  User({required this.name, required this.role, required this.email});
}

List<User> users = [
  User(name: 'John Doe', role: 'Admin', email: 'john@example.com'),
  User(name: 'Jane Smith', role: 'User', email: 'jane@example.com'),
];
