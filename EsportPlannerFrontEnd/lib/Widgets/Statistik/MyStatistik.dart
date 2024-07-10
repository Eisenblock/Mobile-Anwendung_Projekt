
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
  ScrollController _sscrollController = ScrollController();
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
        return (_selectedGame == null || match.videogame.toLowerCase() == _selectedGame!) &&
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
      //_filteredPastMatches = _pastmatches.where((match) => match.videogame.toLowerCase() == _selectedGame).toList();
    });
  }

  void _selectTeam(LoL_Team team) {
    setState(() {
      _selectedTeam = team;
      showTeams = true;
      showPastMatches = false;
    });
  }

    void _scrollToTop() {
    _sscrollController.animateTo(
      0.0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _filterByGame(String game) {
    setState(() {
      /*_selectedGame = game;
      showTeams = false;
      showPastMatches = true;*/
      _filteredPastMatches = _pastmatches.where((match) => match.videogame.toLowerCase() == game).toList();
      _filteredTeams = _teams.where((team) => team.videogame.toLowerCase() == game).toList();
    });
    _scrollToTop();
  }

    void _filterByGameTeam(String game) {
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

        // Filter by selected game
        if (_selectedGame != null && pastMatch.videogame.toLowerCase() != _selectedGame) {
          return SizedBox.shrink(); // Return an empty widget if not the selected game
        }

        // Determine the appropriate game logo
        Widget trailingWidget;
        if (pastMatch.videogame == 'lol') {
          trailingWidget = Image.asset('assets/lol_logo.png', fit: BoxFit.cover);
        } else if (pastMatch.videogame == 'valorant') {
          trailingWidget = Image.asset('assets/valo_logo.webp', fit: BoxFit.cover);
        } else {
          trailingWidget = Icon(Icons.videogame_asset, size: 40);
        }

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
                  subtitle: Text('Date: ${pastMatch.date}  | Time: ${pastMatch.time}Uhr'),
                  trailing: trailingWidget,
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
                            Text('$winner1Points', style: TextStyle(fontWeight: FontWeight.bold)),
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
                      child: Column(
                        children: [
                          Row(
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
                          SizedBox(height: 5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Videogame: ${pastMatch.videogame}'),
                            ],
                          ),
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
                  controller: _sscrollController,
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
                                  ),
                            SizedBox(width: 10),
                            Text('${member.firstName} ${member.lastName}'),
                          ],
                        ),
                        children: [
                          ListTile(
                            title: Text('Position: ${member.role}'),
                            subtitle: Text('Age: ${member.age}'),
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
bottomNavigationBar: BottomAppBar(
  shape: CircularNotchedRectangle(),
  child: Center(
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        GestureDetector(
          onTap: fetchAllTeamsLoL,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group, size: 20), // Icon aus der Flutter-Bibliothek
              SizedBox(width: 5), // Adjust spacing between icon and text
              Text(
                'Teams',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              showPastMatches = true;
              showTeams = false;
            });
            _scrollToTop();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.gamepad, size: 20), // Icon aus der Flutter-Bibliothek
              SizedBox(width: 5), // Adjust spacing between icon and text
              Text(
                'Spiele',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    ),
  ),
),









    );
  }
}