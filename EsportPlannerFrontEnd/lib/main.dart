import 'package:flutter/material.dart';
import 'MyHomePage.dart'; // Annahme: Die MyHomePage befindet sich in der Datei MyHomePage.dart
import 'MyStatistik.dart'; // Annahme: Die MyStatistik befindet sich in der Datei MyStatistik.dart
import 'CalenderPage.dart'; // Annahme: Die CalenderPage befindet sich in der Datei CalenderPage.dart

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/', // Startseite der App
      routes: {
        '/statistik': (context) => MyStatistik(title: 'Statistik Seite'), // Statistikseite
        '/calender': (context) => CalenderPage(title: 'Statistik Seite'), // Statistikseite
      },
      home: MyHomePage(title: 'Flutter Demo Home Page'), // Startseite der App mit zusätzlichen Navigationsbuttons
    );
  }
}

class HomeWithNavigationButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Demo Home Page'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [ 
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/statistik');
              },
              child: Text('Zur Statistikseite navigieren'),
            ),
          ],
        ),
      ),
    );
  }
}
