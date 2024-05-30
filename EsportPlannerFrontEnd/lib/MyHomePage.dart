import 'dart:convert';
import 'TeamInfo.dart';
import 'Loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/CalenderPage.dart';
import 'package:http/http.dart' as http;

TeamInfo teamInfo = TeamInfo('name','', '','', '', '', '' ,'league', 'series', 'leagueurl',DateTime.utc(1900));
Loader loader = Loader();

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  List<TeamInfo> _teamInfos = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

Future<void> fetchTeamInfosLoL() async {
  
     
        List<TeamInfo> teamInfos = [];
        teamInfos = await loader.fetchTeamInfosLoL();

        setState(() {
          _teamInfos = teamInfos;
        });
      
    }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
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
             Expanded(
          child: ListView.builder(
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
                        width: 20,
                        height: 240,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                '${teamInfo.name}',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),                             
                              Text(' ${teamInfo.opponent1}' +' vs' + '  ${teamInfo.opponent2}'),
                              Text('Date: ${teamInfo.date}'),
                              Text('Time: ${teamInfo.time}'),
                              Text('League: ${teamInfo.league}'),
                              
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Visibility(
                                      visible: teamInfo.opponent1url != "keine Daten",
                                      child: Image.network(
                                        teamInfo.opponent1url,
                                        width: 100, // Breite des Bildes
                                        height: 100, // Höhe des Bildes
                                        ),
                                      ), 
                                      Visibility(
                                        visible: teamInfo.opponent1url != "keine Daten",
                                        child: Text(
                                          'vs',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                      ), // Optional: Abstand zwischen den Bildern                                    
                                      SizedBox(width: 10), // Optional: Abstand zwischen den Bildern
                                      Visibility(
                                         visible: teamInfo.opponent2url != "keine Daten",
                                         child: Image.network(
                                          teamInfo.opponent2url,
                                          width: 100, // Breite des Bildes
                                          height: 100, // Höhe des Bildes
                                    ),
                                ),
                              ],)
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
    );
  }
}
