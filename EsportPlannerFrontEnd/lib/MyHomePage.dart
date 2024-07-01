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
            padding: const EdgeInsets.all(8.0),
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
                    Text(
                      '${teamInfo.opponent1} vs ${teamInfo.opponent2}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Row(
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
                          visible: teamInfo.opponent1url != "keine Daten" &&
                              teamInfo.opponent2url != "keine Daten",
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