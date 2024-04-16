import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class TournamentInfo {
  final String original_scheuled_at;
  final String name;
  final String team;

  TournamentInfo({
    required this.original_scheuled_at,
    required this.name,
    required this.team,
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
  List<TournamentInfo> _teamInfo = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fetchData({required bool fetchTournaments}) async {
    const apiKey = 'I33Wd41X3fq__E_nqgl3cgqCT-MceaWMtGJPtyj3ikup7lIIPqo';
    final apiUrl = fetchTournaments
        ? 'https://api.pandascore.co/lol/tournaments/'
        : 'https://api.pandascore.co/lol/teams/';

    final response = await http.get(Uri.parse('$apiUrl?token=$apiKey'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      List<TournamentInfo> info = [];

      for (var item in data) {
        final String original_scheuled_at = fetchTournaments ? item['original_scheuled_at'] ?? '' : '';
        final String name = item['name'] ?? '';
        final String team = item['team'] ?? '';
        final TournamentInfo tournamentInfo = TournamentInfo(
          original_scheuled_at: original_scheuled_at,
          name: name,
          team: team,
        );
        info.add(tournamentInfo);
      }

      setState(() {
        if (fetchTournaments) {
          _tournamentInfo = info;
        } else {
          _teamInfo = info;
        }
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
              onPressed: () {
                fetchData(fetchTournaments: true);
                fetchData(fetchTournaments: false);
              },
              icon: Icon(Icons.download),
              label: Text('Fetch Data'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tournamentInfo.length,
                itemBuilder: (context, index) {
                  final tournament = _tournamentInfo[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Text(
                          tournament.name,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(tournament.original_scheuled_at),
                      ),
                      SizedBox(
                        height: 100.0,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _teamInfo.length,
                          itemBuilder: (context, index) {
                            final team = _teamInfo[index];
                            return Card(
                              child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      team.name,
                                      style: TextStyle(fontSize: 12.0),
                                    ),
                                    Text(
                                      team.team,
                                      style: TextStyle(fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
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
