import 'package:flutter/material.dart';
import 'package:flutter_application_ma/past_matches.dart';
import 'package:provider/provider.dart';
import 'Loader.dart';
import 'user_model.dart';
import 'LoL_Teams.dart';
import 'MyHomePage.dart';

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
  final Loader _loader = Loader();
  bool showPastMatches = true;
  bool showTeams = false;
  final TextEditingController _searchController = TextEditingController();
  LoL_Team? _selectedTeam;
  String? _selectedGame;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterResults);
    fetchMatches();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterResults);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchMatches({String? game}) async {
    try {
      final String userId = Provider.of<UserModel>(context, listen: false).id;
      List<PastMatches> matches = await _loader.fetchPastMatches(userId);
      setState(() {
        _pastmatches = matches;
        _filteredPastMatches = matches;
      });
      print('Fetched ${_pastmatches.length} matches for game: $game');
    } catch (error) {
      print('Error fetching matches: $error');
    }
  }

  Future<void> fetchAllTeamsLoL() async {
    try {
      List<LoL_Team> teams = await _loader.fetchAllTeamsLoL();
      setState(() {
        _teams = teams;
        _filteredTeams = teams;
        showTeams = true;
        showPastMatches = false;
      });
    } catch (error) {
      print('Error fetching teams: $error');
    }
  }

  void _filterResults() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (showTeams) {
        _filteredTeams = _teams.where((team) {
          return team.name.toLowerCase().contains(query) ||
              team.teamMembers.any((member) =>
                  '${member.firstName} ${member.lastName}'.toLowerCase().contains(query));
        }).toList();
      } else if (showPastMatches) {
        _filteredPastMatches = _pastmatches.where((match) {
          return match.videogame.toLowerCase() == _selectedGame &&
              (match.opponent1.toLowerCase().contains(query) ||
                  match.opponent2.toLowerCase().contains(query) ||
                  match.name.toLowerCase().contains(query) ||
                  match.league.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _resetSearch() {
    _searchController.clear();
    setState(() {
      _filteredTeams = _teams;
      _filteredPastMatches = _pastmatches.where((match) => match.videogame.toLowerCase() == _selectedGame).toList();
    });
  }

  void _selectTeam(LoL_Team team) {
    setState(() {
      _selectedTeam = team;
      showTeams = true;
      showPastMatches = false;
    });
  }

  void _filterByGame(String game) {
    setState(() {
      _selectedGame = game;
      showTeams = false;
      showPastMatches = true;
    });
    fetchMatches(game: game);
  }

  Widget buildPastMatches() {
    if (_filteredPastMatches.isEmpty) {
      return Center(child: Text('No past matches available'));
    } else {
      return ListView.builder(
        itemCount: _filteredPastMatches.length,
        itemBuilder: (context, index) {
          final pastMatch = _filteredPastMatches[index];
          int winner1Points = int.parse(pastMatch.winner1);
          int winner2Points = int.parse(pastMatch.winner2);
          bool isWinner1 = winner1Points > winner2Points;
          bool isWinner2 = winner2Points > winner1Points;

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
                    subtitle: Text('Date: ${pastMatch.time} Uhr | Time: ${pastMatch.date}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (pastMatch.opponent1url != 'keine Daten')
                          Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  children: [
                                    Image.network(pastMatch.opponent1url, fit: BoxFit.cover),
                                    if (isWinner1)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(Icons.star, color: Colors.yellow, size: 20),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text('$winner1Points ', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        Text('vs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (pastMatch.opponent2url != 'keine Daten')
                          Column(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                child: Stack(
                                  children: [
                                    Image.network(pastMatch.opponent2url, fit: BoxFit.cover),
                                    if (isWinner2)
                                      Positioned(
                                        top: 0,
                                        right: 0,
                                        child: Icon(Icons.star, color: Colors.yellow, size: 20),
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 5),
                              Text('$winner2Points', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                      ],
                    ),
                  ),
                  ExpansionTile(
                    title: Text('More Info'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              child: Image.network(pastMatch.leagueUrl, fit: BoxFit.cover),
                            ),
                            SizedBox(width: 5),
                            Text('League: ${pastMatch.league}'),
                          ],
                        ),
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
        return Padding(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(team.name, style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: team.teamMembers.length,
                  itemBuilder: (context, memberIndex) {
                    final member = team.teamMembers[memberIndex];
                    return GestureDetector(
                      onTap: () {
                        // Handle tap on player to show details
                        print('Tapped on ${member.firstName} ${member.lastName}');
                        // You can navigate to player details or expand more info here
                      },
                      child: ExpansionTile(
                        title: Row(
                          children: [
                            if (member.image_url.isNotEmpty)
                              Container(
                                width: 50,
                                height: 50,
                                child: Image.network(member.image_url, fit: BoxFit.cover),
                              ),
                            SizedBox(width: 10),
                            Text('${member.firstName} ${member.lastName}'),
                          ],
                        ),
                        children: [
                          ListTile(
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}




  @override
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
            GestureDetector(
              onTap: () {
                _filterByGame('lol');
              },
              child: Image.asset(
                'assets/lol_logo.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            GestureDetector(
              onTap: () {
                _filterByGame('valorant');
              },
              child: Image.asset(
                'assets/valo_logo.webp',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ),
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
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.group),
                  onPressed: fetchAllTeamsLoL,
                ),
                Text('Teams', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.gamepad),
                  onPressed: () {
                    setState(() {
                      showPastMatches = true;
                      showTeams = false;
                    });
                  },
                ),
                Text('Spiele', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
