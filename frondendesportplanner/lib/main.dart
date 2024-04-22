import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class TeamInfo {
  final String name;
  final String date;
  final String league;
  final String series;
  final String leagueurl;
  

  TeamInfo(this.name, this.date,this.league, this.series,this.leagueurl);
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

class _MyHomePageState extends State<MyHomePage> 
{
  int _counter = 0;
  List<TeamInfo> _teamInfos = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> fetchTeamInfosLoL() async 
  {


    final response = await http.get(Uri.parse('http://192.168.0.34:3000/upcoming-matches-lol'));

    if (response.statusCode == 200) {
      final List<dynamic> matches = json.decode(response.body);
      List<TeamInfo> teamInfos = [];

      for (var match in matches) {
        final String name = match['name'];
        final String date = match['begin_at'];
        final String league = match['league']['name'];
        final String leagueurl = match['league']['image_url'];
        final String series = match['serie']['full_name'];
        

        final teamInfo = TeamInfo(name, date,league,series,leagueurl);
        teamInfos.add(teamInfo);
      }

      

      setState(() 
      {
        _teamInfos = teamInfos;
      });
    } else {
      print('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

  Future<void> fetchTeamInfosValorant() async 
  {


    final response = await http.get(Uri.parse('http://192.168.0.34:3000/upcoming-matches-valorant'));

    if (response.statusCode == 200) {
      final List<dynamic> matches = json.decode(response.body);
      List<TeamInfo> teamInfos = [];

      for (var match in matches) {
        final String name = match['name'];
        final String date = match['begin_at'];
        final String league = match['league']['name'];
        final String leagueurl = match['league']['image_url'];
        final String series = match['serie']['name'];
        

        final teamInfo = TeamInfo(name, date,league,series,leagueurl);
        teamInfos.add(teamInfo);
      }

      

      setState(() 
      {
        _teamInfos = teamInfos;
      });
    } else {
      print('Fehler beim Abrufen der Daten: ${response.statusCode}');
    }
  }

@override
Widget build(BuildContext context) 
{
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
            onPressed: fetchTeamInfosLoL,
            icon: Icon(Icons.download),
            label: Text('LoL Matches '),
          ),
          ElevatedButton.icon(
            onPressed: fetchTeamInfosValorant,
            icon: Icon(Icons.download),
            label: Text('valorent Matches '),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _teamInfos.length,
              itemBuilder: (context, index) {
                final teamInfo = _teamInfos[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Name: ${teamInfo.name}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text('Date: ${teamInfo.date}'),
                                Text('League: ${teamInfo.league}'), 
                                Text('Split: ${teamInfo.series}'),
                                if (teamInfo.leagueurl != null) // Überprüfen, ob eine URL vorhanden ist
                        Image.network(
                          teamInfo.leagueurl, // Verwenden Sie die URL aus TeamInfo.series
                          width: 100, // Optional: Breite des Bildes festlegen
                          height: 100, // Optional: Höhe des Bildes festlegen
                        ),                             
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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