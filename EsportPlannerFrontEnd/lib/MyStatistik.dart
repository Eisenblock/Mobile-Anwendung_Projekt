import 'package:flutter/material.dart';
import 'package:flutter_application_ma/past_matches.dart';
import 'package:provider/provider.dart';
import 'Loader.dart';
import 'user_model.dart';
import 'LoL_Teams.dart';

class MyStatistik extends StatefulWidget {
  final String title;

  const MyStatistik({Key? key, required this.title}) : super(key: key);

  @override
  _MyStatistikState createState() => _MyStatistikState();
}

class _MyStatistikState extends State<MyStatistik> {
  List<PastMatches> _pastmatches = [];
  List<LoL_Team> _Teams = [];
  final Loader _loader = Loader();
  String _currentView = 'none'; // Variable to keep track of the current view

  Future<void> fetchPastMatches() async {
    final String userId = Provider.of<UserModel>(context, listen: false).id;
    try {
      List<PastMatches> pastmatch = await _loader.fetchPastMatches(userId);
      setState(() {
        _pastmatches = pastmatch;
        _currentView = 'pastMatches';
      });
      print('Fetched ${_pastmatches.length} past matches');
    } catch (e) {
      print('Failed to fetch team infos: $e');
    }
  }

  Future<void> fetchAllTeamsLoL() async {
    try {
      List<LoL_Team> teams = await _loader.fetchAllTeamsLoL();
      setState(() {
        _Teams = teams;
        _currentView = 'teams';
      });
      print('Fetched ${_Teams.length} Teams');
    } catch (e) {
      print('Failed to fetch team infos: $e');
    }
  }

  String formatDate(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.day}.${dateTime.month}.${dateTime.year}';
  }

  String formatTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return '${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: fetchAllTeamsLoL,
                child: Text('Kader'),
              ),
              ElevatedButton(
                onPressed: fetchPastMatches,
                child: Text('Last Played Matches'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _currentView = 'button3';
                  });
                },
                child: Text('Button 3'),
              ),
            ],
          ),
          SizedBox(height: 20),
          Expanded(
            child: _currentView == 'teams'
                ? buildTeams()
                : _currentView == 'pastMatches'
                    ? buildPastMatches()
                    : Center(child: Text('Select an option')),
          ),
        ],
      ),
    );
  }

  Widget buildPastMatches() {
    if (_pastmatches.isEmpty) {
      return Center(child: Text('No past matches available'));
    } else {
      return ListView.builder(
        itemCount: _pastmatches.length,
        itemBuilder: (context, index) {
          final pastMatches = _pastmatches[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              child: ListTile(
                title: Center(
                  child: Text(
                    '${pastMatches.opponent1} vs ${pastMatches.opponent2}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (pastMatches.opponent1url != 'keine Daten')
                          Image.network(pastMatches.opponent1url, height: 50),
                        Text('vs'),
                        SizedBox(width: 10),
                        if (pastMatches.opponent2url != 'keine Daten')
                          Image.network(pastMatches.opponent2url, height: 50),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gamepad, size: 16.0),
                        SizedBox(width: 5),
                        Text('Game: ${pastMatches.name}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16.0),
                        SizedBox(width: 5),
                        Text('Date: ${formatDate(pastMatches.beginAt)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 16.0),
                        SizedBox(width: 5),
                        Text('Time: ${formatTime(pastMatches.beginAt)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.network(pastMatches.leagueUrl, height: 50),
                        SizedBox(width: 5),
                        Text('League: ${pastMatches.league}'),
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

  Widget buildTeams() {
    if (_Teams.isEmpty) {
      return Center(child: Text('No team infos available'));
    } else {
      return ListView.builder(
        itemCount: _Teams.length,
        itemBuilder: (context, index) {
          final team = _Teams[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              child: ListTile(
                title: Center(
                  child: Column(
                    children: [
                      Text(
                        '${team.name}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('${team.teamMembers}'),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
    }
  }
}
