import 'package:flutter/material.dart';
import '../firebase.dart';
import '../screens/manage_categories.dart';
import '../user_service.dart';

class RoleBasedPopupMenu extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final UserService _userService = UserService();
  final Map<String, dynamic> questionnaire;
  final Function refreshList;

  RoleBasedPopupMenu({
    required this.questionnaire,
    required this.refreshList,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _userService.getUserData(_firebaseService.auth.currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Icon(Icons.error);
        }

        final userData = snapshot.data!;
        final userRole = userData['role'] as int;
        final isAdminOrCreator =
            userRole == 1 || userData['email'] == questionnaire['createdBy'];

        return PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'Manage Questionnaire':
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageCategory(
                      questionnaireId: questionnaire['id'],
                      title: questionnaire['title'],
                    ),
                  ),
                );
                refreshList();
                break;
              case 'Show Results':
                // Implement show results functionality
                break;
              case 'Download Offline':
                // Implement download offline functionality
                break;
              case 'Delete':
                // Implement delete functionality
                break;
              case 'Edit':
                // Implement edit functionality
                break;
            }
          },
          itemBuilder: (BuildContext context) {
            List<PopupMenuEntry<String>> menuItems = [];

            if (isAdminOrCreator) {
              menuItems.addAll([
                PopupMenuItem<String>(
                  value: 'Manage Questionnaire',
                  child: Text('Manage Questionnaire'),
                ),
                PopupMenuItem<String>(
                  value: 'Edit',
                  child: Text('Edit'),
                ),
                PopupMenuItem<String>(
                  value: 'Delete',
                  child: Text('Delete'),
                ),
              ]);
            }

            // These options are available to all users
            menuItems.addAll([
              PopupMenuItem<String>(
                value: 'Show Results',
                child: Text('Show Results'),
              ),
              PopupMenuItem<String>(
                value: 'Download Offline',
                child: Text('Download Offline'),
              ),
            ]);

            return menuItems;
          },
        );
      },
    );
  }
}
