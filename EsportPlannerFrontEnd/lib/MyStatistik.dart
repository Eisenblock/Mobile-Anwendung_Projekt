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
  List<LoL_Team> _teams = [];
  Loader _loader = Loader();
  bool showPastMatches = false;
  bool showTeams = false;

  @override
  void initState() {
    super.initState();
    // Load initial data when the widget is first created
    fetchPastMatches();
  }

  Future<void> fetchPastMatches() async {
    final String userId = Provider.of<UserModel>(context, listen: false).id;
   
      List<PastMatches> pastmatch = await _loader.fetchPastMatches(userId);
      setState(() {
        _pastmatches = pastmatch;
      });
      print('Fetched ${_pastmatches.length} past matches');
  } 

  Future<void> fetchAllTeamsLoL() async {
    
      List<LoL_Team> teams = await _loader.fetchAllTeamsLoL();
      setState(() {
        _teams = teams;
      });
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
                onPressed: () {
                  fetchAllTeamsLoL();
                  setState(() {
                    showTeams = true;
                    showPastMatches = false;
                  });
                },
                child: Text('Kader'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    showPastMatches = true;
                    showTeams = false;
                  });
                },
                child: Text('Last Played Matches'),
              ),
            ],
          ),
          SizedBox(height: 20),
          if (showPastMatches)
            Expanded(child: buildPastMatches()), // `Expanded` für das richtige Layout mit `ListView`
          if (showTeams)
            Expanded(child: buildTeams()), // `Expanded` für das richtige Layout mit `ListView`
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
                        Text('Date: ${pastMatches.date}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.access_time, size: 16.0),
                        SizedBox(width: 5),
                        Text('Time: ${pastMatches.time}'),
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
  if (_teams.isEmpty) {
    return Center(child: CircularProgressIndicator());
  } else {
    return ListView.builder(
      itemCount: _teams.length,
      itemBuilder: (context, index) {
        final team = _teams[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      team.name,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  children: team.teamMembers.map((member) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(member.image_url, height: 50),
                          SizedBox(height: 8), // Optionaler Abstand zwischen Bild und Text
                          Text('${member.firstName} ${member.lastName}'),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

}
