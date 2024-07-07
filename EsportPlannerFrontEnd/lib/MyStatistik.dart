import 'package:flutter/material.dart';
import 'package:flutter_application_ma/past_matches.dart'; // Import your PastMatches model
import 'package:provider/provider.dart';
import 'Loader.dart';
import 'user_model.dart';
import 'LoL_Teams.dart';
import 'MyHomePage.dart';
 // Import your HomePage

class MyStatistik extends StatefulWidget {
  final String title;

  const MyStatistik({Key? key, required this.title}) : super(key: key);

  @override
  _MyStatistikState createState() => _MyStatistikState();
}

class _MyStatistikState extends State<MyStatistik> {
  List<PastMatches> _pastmatches = [];
  List<PastMatches> _filteredPastMatches = [];
  List<LoL_Team> _teams = [];
  List<LoL_Team> _filteredTeams = [];
  Loader _loader = Loader();
  bool showPastMatches = true; // Show past matches by default
  bool showTeams = false;
  TextEditingController _searchController = TextEditingController();
  LoL_Team? _selectedTeam; // Track the selected team

  @override
  void initState() {
    super.initState();
    fetchPastMatches();
    _searchController.addListener(_filterResults);
  }

  Future<void> fetchPastMatches() async {
    try {
      final String userId = Provider.of<UserModel>(context, listen: false).id;
      List<PastMatches> pastMatches = await _loader.fetchPastMatches(userId);
      setState(() {
        _pastmatches = pastMatches;
        _filteredPastMatches = pastMatches;
      });
      print('Fetched ${_pastmatches.length} past matches');
    } catch (error) {
      print('Error fetching past matches: $error');
      // Handle error as needed
    }
  }

  Future<void> fetchAllTeamsLoL() async {
    try {
      List<LoL_Team> teams = await _loader.fetchAllTeamsLoL();
      setState(() {
        _teams = teams;
        _filteredTeams = teams;
      });
    } catch (error) {
      print('Error fetching teams: $error');
      // Handle error as needed
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    if (showTeams) {
      setState(() {
        _filteredTeams = _teams.where((team) {
          return team.name.toLowerCase().contains(query) ||
              team.teamMembers.any((member) =>
                  '${member.firstName} ${member.lastName}'.toLowerCase().contains(query));
        }).toList();
      });
    } else if (showPastMatches) {
      setState(() {
        _filteredPastMatches = _pastmatches.where((match) {
          return match.opponent1.toLowerCase().contains(query) ||
              match.opponent2.toLowerCase().contains(query) ||
              match.name.toLowerCase().contains(query) ||
              match.league.toLowerCase().contains(query);
        }).toList();
      });
    }
  }

  void _resetSearch() {
    _searchController.clear();
    setState(() {
      _filteredTeams = _teams;
      _filteredPastMatches = _pastmatches;
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

  void _selectTeam(LoL_Team team) {
    setState(() {
      _selectedTeam = team;
      showTeams = true;
      showPastMatches = false;
    });
  }

  void _navigateToHomePage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage(title: 'Home')),
    );
  }

  void _filterByGame(String game) {
    setState(() {
      if (game == 'lol') {
        showPastMatches = true;
        showTeams = false;
      } else if (game == 'valorant') {
        fetchAllTeamsLoL(); // Adjust if you have a specific fetch function for Valorant teams
        showTeams = true;
        showPastMatches = false;
      }
    });
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  onPressed: _resetSearch,
                  tooltip: 'Refresh',
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: showPastMatches ? buildPastMatches() : buildTeams(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Handle action button press
        },
        tooltip: 'Action',
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(Icons.home),
              onPressed: () {
                _navigateToHomePage(context);
              },
            ),
            IconButton(
              icon: Icon(Icons.group),
              onPressed: () {
                fetchAllTeamsLoL();
                setState(() {
                  showTeams = true;
                  showPastMatches = false;
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.gamepad),
              onPressed: () {
                setState(() {
                  showPastMatches = true;
                  showTeams = false;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

 Widget buildPastMatches() {
  if (_filteredPastMatches.isEmpty) {
    return Center(child: Text('No past matches available'));
  } else {
    return ListView.builder(
      itemCount: _filteredPastMatches.length,
      itemBuilder: (context, index) {
        final pastMatch = _filteredPastMatches[index];
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(
                    '${pastMatch.opponent1} vs ${pastMatch.opponent2}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Date: ${pastMatch.time} | Time: ${pastMatch.date}'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (pastMatch.opponent1url != 'keine Daten')
                        Column(
                          children: [
                            Image.network(pastMatch.opponent1url, height: 50),
                            SizedBox(height: 5),
                            Text(
                              pastMatch.winner1,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      Text('vs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      if (pastMatch.opponent2url != 'keine Daten')
                        Column(
                          children: [
                            Image.network(pastMatch.opponent2url, height: 50),
                            SizedBox(height: 5),
                            Text(
                              pastMatch.winner2,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(pastMatch.leagueUrl, height: 50),
                    SizedBox(width: 5),
                    Text('League: ${pastMatch.league}'),
                  ],
                ),
                // Nested ExpansionTile for additional information
                ExpansionTile(
                  title: Text('More Info'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Additional information about the match can go here.'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}



  Widget buildTeams() {
    if (_filteredTeams.isEmpty) {
      return Center(child: Text('No teams found'));
    } else {
      return ListView.builder(
        itemCount: _filteredTeams.length,
        itemBuilder: (context, index) {
          final team = _filteredTeams[index];
          return GestureDetector(
            onTap: () {
              _selectTeam(team);
            },
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            team.name,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
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
                             if (member.image_url != 'Unknown')
                              Image.network(
                                member.image_url,
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
                              ), // Placeholder image if image_url is empty
                              SizedBox(height: 8),
                              Text('${member.firstName} ${member.lastName}'),
                            ],
                          ),
                        );
                      }).toList(),
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