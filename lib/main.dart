import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:pio_survey/firebase_options.dart';
import 'package:pio_survey/screens/dashboard.dart';
import 'package:pio_survey/screens/login.dart';
import 'package:pio_survey/screens/list_questionnaire.dart';
import 'package:pio_survey/screens/manage_users.dart';
import 'package:pio_survey/screens/offline_response.dart';
import 'package:pio_survey/user_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: "pio survey",
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final UserService _userService = UserService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIO SURVEY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: AuthWrapper(_userService),
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) => Dashboard(),
        '/questionnaires': (context) => ListQuestionnaireScreen(),
        '/offlineResponse': (context) => OfflineResponseScreen(),
        '/manageUser': (context) => ManageUserScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final UserService _userService;

  AuthWrapper(this._userService);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          auth.User? user = snapshot.data;
          if (user == null) {
            return LoginScreen();
          }
          return FutureBuilder<String>(
            future: _userService.getInitialRoute(user.uid),
            builder: (context, routeSnapshot) {
              if (routeSnapshot.connectionState == ConnectionState.done) {
                if (routeSnapshot.data == '/dashboard') {
                  return Dashboard();
                } else if (routeSnapshot.data == '/questionnaires') {
                  return ListQuestionnaireScreen();
                }
              }
              // Show loading indicator while determining the route
              return Scaffold(body: Center(child: CircularProgressIndicator()));
            },
          );
        }
        // Show loading indicator while checking auth state
        return Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
