import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'MyHomePage.dart'; // Die MyHomePage befindet sich in der Datei MyHomePage.dart
import 'MyStatistik.dart'; // Die MyStatistik befindet sich in der Datei MyStatistik.dart
import 'CalenderPage.dart'; // Die CalenderPage befindet sich in der Datei CalenderPage.dart
import 'LoginScreen.dart';// Die LoginScreen befindet sich in der Datei LoginScreen.dart
import 'user_model.dart'; // Die UserModel befindet sich in der Datei user_model.dart
import 'SettingPage.dart'; // Die SettingPage befindet sich in der Datei SettingPage.dart
import 'anmeldung.dart'; // Die RegistrationForm befindet sich in der Datei anmeldung.dart
import 'AdvanceSettingPage.dart'; // Die AdvanceSettingPage befindet sich in der Datei AdvanceSettingPage.dart

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(), // Standardlichtmodus
    darkTheme: ThemeData.dark(), // Standard-Dunkelmodus
      initialRoute: '/login',
      routes: {
        '/statistik': (context) => MyStatistik(title: 'Statistik Seite'),
        '/calender': (context) => CalendarPage(title: 'Calender Page',),
        '/login': (context) => LoginScreen(),
        '/MyHomePage': (context) => MyHomePage(title: 'Esport Planner'),
        '/settings': (context) => SettingsPage(),
        '/anmeldung': (context) => RegistrationForm(),
        '/login': (context) => LoginScreen(),
        '/advanceSetting': (context) => AdvanceSettingPage(),
      },
    );
  }
}