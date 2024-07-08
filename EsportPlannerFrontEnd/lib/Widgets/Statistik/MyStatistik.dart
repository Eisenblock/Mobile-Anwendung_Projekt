

import 'package:flutter/material.dart';
import 'package:flutter_application_ma/Widgets/Objects/past_matches.dart'; // Import your PastMatches model
import 'package:provider/provider.dart';
import '../../Data/Loader.dart';
import '../Objects/user_model.dart';
import '/Widgets/Objects/LoL_Teams.dart';
import '/Widgets/Homepage/MyHomePage.dart'; // Import your HomePage

class MyStatistik extends StatefulWidget {
  final String title;

  const MyStatistik({Key? key, required this.title}) : super(key: key);

  @override
  _MyStatistikState createState() => _MyStatistikState();
}

class _MyStatistikState extends State<MyStatistik> {

  //variables
  List<PastMatches> _pastmatches = [];
  List<PastMatches> _filteredPastMatches = [];
  List<LoL_Team> _teams = [];
  List<LoL_Team> _filteredTeams = [];
  Loader _loader = Loader();
  bool showPastMatches = true; // Show past matches by default
  bool showTeams = false;
  TextEditingController _searchController = TextEditingController();
  LoL_Team? _selectedTeam; // Track the selected team
  String? _selectedGame; // Track the selected game (lol or valorant)

  @override
  void initState() {
    super.initState();
    fetchMatches(); // Fetch both LOL and Valorant matches initially
    _searchController.addListener(_filterResults);
  }


//Get the past matches from the backend
  Future<void> fetchMatches() async {
    try {
      final String userId = Provider.of<UserModel>(context, listen: false).id;
      List<PastMatches> matches = await _loader.fetchPastMatches(userId);
      print("----------------------------------------------");
      print(matches);

      // Filter matches to only include lol or valorant
      matches = matches.where((match) => match.videogame.toLowerCase() == 'lol' || match.videogame.toLowerCase() == 'valorant').toList();

      setState(() {
        _pastmatches = matches;
        _filteredPastMatches = matches;
      });
      print('Fetched ${_pastmatches.length} matches');
    } catch (error) {
      print('Error fetching matches: $error');
      // Handle error as needed
    }
  }

    Future<void> fetchAllTeamsLoL() async {
    try {
      List<LoL_Team> teams = await _loader.fetchAllTeamsLoL();
      showPastMatches = false;
      setState(() {
        _teams = teams;
        _filteredTeams = teams;
      });
    } catch (error) {
      print('Error fetching teams: $error');
      // Handle error as needed
    }
  }


//Change the build to show the past matches (valo or lol)
  Future<void> changeBuild_pastMatches() async {
   bool _showPastMatches = true;
    setState(() {
      showPastMatches = _showPastMatches;
    });
  }

//Filter the results : search function
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
          return match.videogame.toLowerCase() == _selectedGame &&
              (match.opponent1.toLowerCase().contains(query) ||
                  match.opponent2.toLowerCase().contains(query) ||
                  match.name.toLowerCase().contains(query) ||
                  match.league.toLowerCase().contains(query));
        }).toList();
      });
    }
  }


//Reset to default
  void _resetSearch() {
    _searchController.clear();
    setState(() {
      _filteredTeams = _teams;
      _filteredPastMatches = _pastmatches.where((match) => match.videogame.toLowerCase() == _selectedGame).toList();
    });
  }

//Show the Teams
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

//Filter the games (lol or valorant)
  void _filterByGame(String game) {
    setState(() {
      _selectedGame = game;
      showTeams = game != 'lol'; // Show teams view for Valorant
      showPastMatches = game == 'lol'; // Show past matches view for LOL
      _filteredPastMatches = _pastmatches.where((match) => match.videogame.toLowerCase() == game).toList();
    });
  }


//Build the Statistik
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
                  'assets/valorant_logo.png',
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
                    onPressed: () {
                      fetchAllTeamsLoL();
                    },
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
                      changeBuild_pastMatches();
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


//Build the Past Matches Databox
  Widget buildPastMatches() {
    if (_filteredPastMatches.isEmpty) {
      return Center(child: Text('No past matches available'));
    } else {
      return ListView.builder(
        itemCount: _filteredPastMatches.length,
        itemBuilder: (context, index) {
          final pastMatch = _filteredPastMatches[index];

          // Convert winner1 and winner2 from String to int
          int winner1Points = int.parse(pastMatch.winner1);
          int winner2Points = int.parse(pastMatch.winner2);

          // Determine the winner based on points
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
                                width: 50, // Fixed width for the logo
                                height: 50, // Fixed height for the logo
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
                              Text(
                                '$winner1Points ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        Text('vs', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        if (pastMatch.opponent2url != 'keine Daten')
                          Column(
                            children: [
                              Container(
                                width: 50, // Fixed width for the logo
                                height: 50, // Fixed height for the logo
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
                              Text(
                                '$winner2Points',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  // Nested ExpansionTile for additional information
                  ExpansionTile(
                    title: Text('More Info'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50, // Fixed width for the logo
                              height: 50, // Fixed height for the logo
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


//Build the Teams Databox
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
