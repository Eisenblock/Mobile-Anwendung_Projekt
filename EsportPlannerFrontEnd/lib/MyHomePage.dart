import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'package:flutter_application_ma/LoginScreen.dart';
import 'LoginScreen.dart';
import 'TeamInfo.dart';
import 'Loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/CalenderPage.dart';
import 'package:http/http.dart' as http;

TeamInfo teamInfo = TeamInfo('name','', '','', '', '', '' ,'league', 'series', 'leagueurl',DateTime.utc(1900), '');
Loader loader = Loader();
LoginScreen loginScreen = LoginScreen();

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();

  
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String id = '';
  List<TeamInfo> _teamInfos = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

Future<void> fetchTeamInfosLoL() async {
  
     
        List<TeamInfo> teamInfos = [];
        final id = Provider.of<UserModel>(context, listen: false).id;
        teamInfos = await loader.fetchTeamInfosLoL(id);  
        print("++++++"+id);     // ID des Benutzers übergeben  

        setState(() {
          _teamInfos = teamInfos;
        });
      
    }

    Future<void> SetIDUser(String _id) async {     

        setState(() {
         id = _id;       // ID des Benutzers übergeben
        });
      
    }


@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      title: Text(widget.title),
      actions: [
        IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            Navigator.pushNamed(context, '/settings');
          },
        ),
      ],
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          buildButtons(), // Zeige die Buttons an
          SizedBox(height: 20), // Fügen Sie einen Abstand zwischen den Buttons und der Team-Info-Liste hinzu
          Expanded(
            child: buildTeamInfoList(), // Zeige die Team-Info-Liste an
          ),
        ],
      ),
    ),
  );
}

// Methode zum Erstellen der Buttons
Widget buildButtons() {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      ElevatedButton.icon(
        onPressed: fetchTeamInfosLoL,
        icon: Icon(Icons.download),
        label: Text('LoL Matches'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/statistik');
        },
        child: Text('Button statistik'),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/calender');
        },
        child: Text('Button calender'),
      ),
    ],
  );
}

// Methode zum Erstellen der Team-Info-Liste
Widget buildTeamInfoList() {
  return ListView.builder(
    itemCount: _teamInfos.length,
    itemBuilder: (context, index) {
      final teamInfo = _teamInfos[index];
      return Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 240,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Text(
                          '${teamInfo.opponent1} vs ${teamInfo.opponent2}',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Visibility(
                              visible: teamInfo.opponent1url != "keine Daten",
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  teamInfo.opponent1url,
                                  width: 100,
                                  height: 100,
                                ),
                              ),      
                            ),
                            Visibility(
                              visible: teamInfo.opponent1url != "keine Daten",
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  'vs',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: teamInfo.opponent2url != "keine Daten",
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.network(
                                  teamInfo.opponent2url,
                                  width: 100,
                                  height: 100,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                        Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 16.0),
                            SizedBox(width: 4.0),
                            Text('${teamInfo.date}'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 16.0),
                            SizedBox(width: 4.0),
                            Text('${teamInfo.time}'),
                          ],
                        ),
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
  );
}



}
