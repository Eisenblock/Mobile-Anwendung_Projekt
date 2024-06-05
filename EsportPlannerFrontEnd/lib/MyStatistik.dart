import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'Loader.dart';
import 'TeamInfo.dart';
import 'user_model.dart';


class MyStatistik extends StatefulWidget {
  final String title;

  const MyStatistik({Key? key, required this.title}) : super(key: key);

  @override
  _MyStatistikState createState() => _MyStatistikState();
}

class _MyStatistikState extends State<MyStatistik> {
  List<TeamInfo> _teamInfos = [];
  final Loader _loader = Loader();

  Future<void> fetchTeamInfosLoL() async {
    final String userId = Provider.of<UserModel>(context, listen: false).id;

    print('User ID: $userId');

    try {
      List<TeamInfo> teamInfos = await _loader.fetchTeamInfosLoL(userId);
      print('Team Infos from API: $teamInfos'); // Print the teamInfos received from the API
      setState(() {
        _teamInfos = teamInfos;
      });
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
            onPressed: fetchTeamInfosLoL,
            child: Text('Load LoL Team Infos'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: buildTeamInfoList(),
          ),
        ],
      ),
    );
  }

  Widget buildTeamInfoList() {
    if (_teamInfos.isEmpty) {
      return Center(child: Text('No team infos available'));
    } else {
      return ListView.builder(
        itemCount: _teamInfos.length,
        itemBuilder: (context, index) {
          final teamInfo = _teamInfos[index];
          return Padding(
            padding: const EdgeInsets.all(4.0),
            child: Card(
              child: ListTile(
                title: Text(
                    '${teamInfo.opponent1} vs ${teamInfo.opponent2}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (teamInfo.opponent1url != 'keine Daten')
                      Image.network(teamInfo.opponent1url, height: 50),
                    if (teamInfo.opponent2url != 'keine Daten')
                      Image.network(teamInfo.opponent2url, height: 50),
                    Text('Date: ${teamInfo.date}'),
                    Text('Time: ${teamInfo.time}'),
                    Text('League: ${teamInfo.league}'),
                    Text('Series: ${teamInfo.series}'),
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
