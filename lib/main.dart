import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class TournamentInfo {
  final String beginAt;
  final String name;

  TournamentInfo({
    required this.beginAt,
    required this.name,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<TournamentInfo> _tournamentInfo = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fetchTeamNames() async {
    const apiKey = 'I33Wd41X3fq__E_nqgl3cgqCT-MceaWMtGJPtyj3ikup7lIIPqo';
    const apiUrl = 'https://api.pandascore.co/lol/tournaments/';

    final response = await http.get(Uri.parse('$apiUrl?token=$apiKey'));

    if (response.statusCode == 200) {
      final List<dynamic> tournaments = json.decode(response.body);
      List<TournamentInfo> info = [];

      for (var tournament in tournaments) {
        final String beginAt = tournament['begin_at'] ?? '';
        final String name = tournament['name'] ?? '';
        final TournamentInfo tournamentInfo = TournamentInfo(
          beginAt: beginAt,
          name: name,
        );
        info.add(tournamentInfo);
      }

      setState(() {
        _tournamentInfo = info;
      });
    } else {
      print('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline6,
            ),
            ElevatedButton.icon(
              onPressed: fetchTeamNames,
              icon: Icon(Icons.download),
              label: Text('Fetch Data'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tournamentInfo.length,
                itemBuilder: (context, index) {
                  final info = _tournamentInfo[index];
                  return ListTile(
                    title: Text(info.name),
                    subtitle: Text(info.beginAt),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
