import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Stelle sicher, dass du das benötigte Paket importierst
import 'user_model.dart';
import 'Loader.dart';
import 'TeamInfo.dart';
import 'LoginScreen.dart';

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

  @override
  void initState() {
    super.initState();
    fetchTeamInfosLoL();
  }

  Future<void> fetchTeamInfosLoL() async {
    List<TeamInfo> teamInfos = [];
    final id = Provider.of<UserModel>(context, listen: false).id;
    teamInfos = await loader.fetchTeamInfosLoL(id);
    print("++++++" + id); // ID des Benutzers übergeben

    setState(() {
      _teamInfos = teamInfos;
    });
  }

  Future<void> SetIDUser(String _id) async {
    setState(() {
      id = _id; // ID des Benutzers übergeben
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
      body: buildTeamInfoList(),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchTeamInfosLoL,
        tooltip: 'Refresh',
        child: Icon(Icons.refresh),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.dashboard),
              onPressed: () {
                Navigator.pushNamed(context, '/statistik');
              },
            ),
            IconButton(
              icon: Icon(Icons.calendar_today),
              onPressed: () {
                Navigator.pushNamed(context, '/calender');
              },
            ),
          ],
        ),
      ),
    );
  }

  // Methode zum Erstellen der Team-Info-Liste
Widget buildTeamInfoList() {
  if (_teamInfos.isEmpty) {
    return Center(
      child: CircularProgressIndicator(),
    );
  } else {
    return ListView.builder(
      itemCount: _teamInfos.length,
      itemBuilder: (context, index) {
        final teamInfo = _teamInfos[index];
        return Padding(
          padding: const EdgeInsets.all(16.0), // Padding um die gesamte Karte
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0), // Padding um den Text
                    child: Text(
                      '${teamInfo.name}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.all(16.0), // Padding um die gesamte Row
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            if (teamInfo.opponent1url != 'keine Daten')
                              Image.network(
                                teamInfo.opponent1url,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Center(
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            SizedBox(height: 4),
                            if(teamInfo.opponent1 != 'keine Daten')
                            Text(
                              teamInfo.opponent_short1,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0), // Padding um den "vs" Text
                          child: Text(
                            'vs',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                        SizedBox(width: 8),
                        Column(
                          children: [
                            if (teamInfo.opponent2url != 'keine Daten')
                              Image.network(
                                teamInfo.opponent2url,
                                height: 80,
                                width: 80,
                                fit: BoxFit.cover,
                              )
                            else
                              Container(
                                height: 80,
                                width: 80,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(8.0),
                                  border: Border.all(color: Colors.black),
                                ),
                                child: Center(
                                  child: Text(
                                    '?',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 12,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            SizedBox(height: 4),
                            if(teamInfo.opponent2 != 'keine Daten')
                            Text(                           
                              teamInfo.opponent_short2,
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16.0),
                      SizedBox(width: 4.0),
                      Text('${teamInfo.date}'),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 16.0),
                      SizedBox(width: 4.0),
                      Text('${teamInfo.time}'),
                    ],
                  ),
                  Text(
                    teamInfo.videoGame,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

}
