import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_service.dart';

class AppDrawer extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: _getUserRole(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          int userRole =
              snapshot.data ?? 2; // Default to user role if not found
          return Drawer(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.blue,
                  ),
                  child: Text(
                    'PIO Survey',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                    ),
                  ),
                ),
                if (userRole == 1) ...[
                  ListTile(
                    leading: Icon(Icons.dashboard),
                    title: Text('Dashboard'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/dashboard');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.people),
                    title: Text('Manage Users'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/manageUser');
                    },
                  ),
                ],
                ListTile(
                  leading: Icon(Icons.question_answer),
                  title: Text('Questionnaires'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/questionnaires');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.offline_bolt),
                  title: Text('Offline Responses'),
                  onTap: () {
                    Navigator.of(context)
                        .pushReplacementNamed('/offlineResponse');
                  },
                ),
                Divider(),
                ListTile(
                  leading: Icon(Icons.exit_to_app),
                  title: Text('Logout'),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.of(context).pushReplacementNamed('/login');
                  },
                ),
              ],
            ),
          );
        }
        // Show a loading indicator while fetching the user role
        return Drawer(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }

  Future<int> _getUserRole() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      Map<String, dynamic>? userData = await _userService.getUserData(user.uid);
      return userData?['role'] ?? 2; // Default to user role if not found
    }
    return 2; // Default to user role if no user is logged in
  }
}
