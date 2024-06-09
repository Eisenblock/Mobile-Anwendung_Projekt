import 'package:flutter/material.dart';
import 'package:flutter_application_ma/past_matches.dart';
import 'package:provider/provider.dart';
import 'Loader.dart';
import 'user_model.dart';

class MyStatistik extends StatefulWidget {
  final String title;

  const MyStatistik({Key? key, required this.title}) : super(key: key);

  @override
  _MyStatistikState createState() => _MyStatistikState();
}

class _MyStatistikState extends State<MyStatistik> {
  List<PastMatches> _pastmatches = [];
  final Loader _loader = Loader();

  Future<void> fetchPastMatches() async {
    final String userId = Provider.of<UserModel>(context, listen: false).id;
    try {
      List<PastMatches> pastmatch = await _loader.fetchPastMatches(userId);
      setState(() {
        _pastmatches = pastmatch;
      });
      print('Fetched ${_pastmatches.length} past matches');
    } catch (e) {
      print('Failed to fetch team infos: $e');
    }
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
                onPressed: () {},
                child: Text('Button 1'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Button 2'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: Text('Button 3'),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: fetchPastMatches,
            child: Text('Past Played Matches'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: buildPastMatches(),
          ),
        ],
      ),
    );
  }

  Widget buildPastMatches() {
    if (_pastmatches.isEmpty) {
      return Center(child: Text('No team infos available'));
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
                        SizedBox(width: 10), // Optional: Adds some space between images
                        if (pastMatches.opponent2url != 'keine Daten')
                          Image.network(pastMatches.opponent2url, height: 50),
                      ],
                    ),
                    SizedBox(height: 10), // Optional: Adds some space between row and text
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.gamepad, size: 16.0),
                        SizedBox(width: 5), // Adds some space between the icon and text
                        Text('Game: ${pastMatches.name}'), 
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.calendar_today, size: 16.0),
                        SizedBox(width: 5), // Adds some space between the icon and text
                        Text('Date: ${pastMatches.beginAt}'),
                      ],
                    ),


                    if (pastMatches.leagueUrl != 'keine Daten')
                          Image.network(pastMatches.leagueUrl, height: 50),

                     Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.leaderboard_rounded, size: 16.0),
                        SizedBox(width: 5), // Adds some space between the icon and text
                        Text('leauge: ${pastMatches.league}'),
                      ]
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