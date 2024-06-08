import 'package:flutter/material.dart';
import 'package:flutter_application_ma/past_matches.dart';
import 'package:provider/provider.dart%20';
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
      }
    
     catch (e) {
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
            onPressed:fetchPastMatches,
            child: Text('Load LoL Team Infos'),
          ),
          SizedBox(height: 20),
          Expanded(
            child: buildpastmatches(),
          ),
        ],
      ),
    );
  }

  Widget buildpastmatches() {
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
                title: Text(
                    '${pastMatches.name}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //if (teamInfo.opponent1url != 'keine Daten')
                      //Image.network(teamInfo.opponent1url, height: 50),
                    //if (teamInfo.opponent2url != 'keine Daten')
                      //Image.network(teamInfo.opponent2url, height: 50),
                    Text('Date: ${pastMatches.name}'),
                    Text('game: ${pastMatches.beginAt}'),
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
