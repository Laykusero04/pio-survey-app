import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            child: Text(
              'Menu',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Dashboard'),
            onTap: () {
              // Handle Dashboard tap
              Navigator.of(context).pushReplacementNamed('/dashboard');
            },
          ),
          ListTile(
            leading: Icon(Icons.dashboard),
            title: Text('Offline Response'),
            onTap: () {
              // Handle Dashboard tap
              Navigator.of(context).pushReplacementNamed('/offlineResponse');
            },
          ),
          ListTile(
            leading: Icon(Icons.people),
            title: Text('Manage User'),
            onTap: () {
              // Handle Manage User tap
              Navigator.of(context).pushReplacementNamed('/manageUser');
            },
          ),
          ListTile(
            leading: Icon(Icons.question_answer),
            title: Text('Questionnaire'),
            onTap: () {
              // Handle Manage Questionnaire tap
              Navigator.of(context).pushReplacementNamed('/questionnaires');
            },
          ),
          // ListTile(
          //   leading: Icon(Icons.question_answer),
          //   title: Text('Manage Questionnaire'),
          //   onTap: () {
          //     // Handle Manage Questionnaire tap
          //     Navigator.of(context)
          //         .pushReplacementNamed('/manageQuestionnaire');
          //   },
          // ),
          ListTile(
            leading: Icon(Icons.logout),
            title: Text('Logout'),
            onTap: () {
              // Handle Logout tap
              // Add your logout logic here
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
