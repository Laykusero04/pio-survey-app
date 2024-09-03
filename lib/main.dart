import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pio_survey/firebase_options.dart';
import 'package:pio_survey/screens/dashboard.dart';
import 'screens/login.dart';
import 'screens/list_questionnaire.dart';
import 'screens/manage_users.dart';
import 'screens/offline_response.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      name: "pio survey", options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PIO SURVEY',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/dashboard',
      routes: {
        '/dashboard': (context) => const Dashboard(),
        '/offlineResponse': (context) => OfflineResponseScreen(),
        '/manageUser': (context) => ManageUserScreen(),
        '/questionnaires': (context) => ListQuestionnaireScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
