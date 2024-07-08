import 'Loader.dart';
import 'LoL_Leagues.dart';
import 'LoL_Teams.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'user_model.dart';

class AdvanceSettingPage extends StatefulWidget {
  AdvanceSettingPage({Key? key}) : super(key: key);

  @override
  _AdvanceSettingPageState createState() => _AdvanceSettingPageState();
}

class _AdvanceSettingPageState extends State<AdvanceSettingPage> {
  String selectedLeague = '';
  String selectedTeam = '';
  List<LoL_Leagues> filteredLeagues = [];
  List<LoL_Team> teams = [];
  List<LoL_Team> filteredTeams = [];
  Loader loader = Loader();
  List<LoL_Leagues> allleagues = [];
  List<bool> selectedOptions_leagues = [];
  List<bool> selectedOptions_teams = [];
  String id = '';
  bool lolTrue = false;
  bool valTrue = false;
  String ip_Adress = "192.168.0.34";

  @override
  void initState() {
    super.initState();
    fetchAllOptions().then((_) {
      setState(() {
        selectedOptions_leagues = List<bool>.generate(allleagues.length, (index) => false);
        selectedOptions_teams = List<bool>.generate(teams.length, (index) => false);
      });
    });
  }

  Future<void> fetchAllOptions() async {
    List<LoL_Leagues> _leagues = [];
    List<LoL_Team> _teams = [];

    _leagues = await loader.fetchAllLeagues();
    _teams = await loader.fetchAllTeamsLoL();  // Pass the ipAddress argument here

    setState(() {
      allleagues = _leagues;
      teams = _teams;
    });
    print(allleagues[0].name);
    await fetchAllOptionss();
  }

  Future<void> fetchAllOptionss() async {
    List<LoL_Team> _teams = [];

    _teams = await loader.fetchAllTeamsLoL();  // Pass the ipAddress argument here

    setState(() {
      teams = _teams;
    });
    print(teams[0].name + 'teams');
  }

  List<LoL_Team> getFilteredTeams() {
    return teams.where((team) {
      if (lolTrue) {
        return team.videogame == 'lol';
      } else if (valTrue) {
        return team.videogame == 'valorant';
      }
      return false;
    }).toList();
  }

  List<LoL_Leagues> getFilteredLeagues() {
    return allleagues.where((league) {
      if (lolTrue) {
        return league.videoGame == 'lol';
      } else if (valTrue) {
        return league.videoGame == 'valorant';
      }
      return false;
    }).toList();
  }

  void ChangeSettingsLoL() {
    setState(() {
      lolTrue = true;
      valTrue = false;
      filteredLeagues = getFilteredLeagues();
      filteredTeams = getFilteredTeams();
    });
    print("lol" + allleagues[0].videoGame);
  }

  void ChangeSettingsValo() {
    setState(() {
      lolTrue = false;
      valTrue = true;
      filteredLeagues = getFilteredLeagues();
      filteredTeams = getFilteredTeams();
    });
    print("valo" + allleagues[0].videoGame);
  }

  Future<void> saveSettingsToBackend(List<String> selectedTeams, List<String> selectedLeagues) async {
    final id = Provider.of<UserModel>(context, listen: false).id;
    final url = 'http://192.168.0.34:3000/user/$id'; // Ersetze dies durch die URL deines Backends
    var response;

    print(lolTrue);

    if (lolTrue) {
      response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'selectedTeams_lol': selectedTeams,
          'selectedLeagues_lol': selectedLeagues,
        }),
      );
    }

    if (valTrue) {
      response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'selectedTeams_valo': selectedTeams,
          'selectedLeagues_valo': selectedLeagues,
        }),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('LoL'),
                  ElevatedButton(
                    onPressed: () {
                      ChangeSettingsLoL();
                    },
                    child: Text('Change'),
                  ),
                  Text('Valorant'),
                  ElevatedButton(
                    onPressed: () {
                      ChangeSettingsValo();
                    },
                    child: Text('Change'),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  'Choose your Team:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredLeagues.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(filteredLeagues[index].name),
                    value: selectedOptions_leagues[index], // Hier könnte eine Korrektur notwendig sein, wenn selectedOptions nicht für die Ligen verwendet werden soll
                    onChanged: (bool? value) {
                      setState(() {
                        selectedOptions_leagues[index] = value!;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20), // Add some space between sections
              Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
                child: Text(
                  'Choose your Team:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: filteredTeams.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(filteredTeams[index].name),
                    value: selectedOptions_teams[index], // Hier könnte eine Korrektur notwendig sein, wenn selectedOptions nicht für die Ligen verwendet werden soll
                    onChanged: (bool? value) {
                      setState(() {
                        selectedOptions_teams[index] = value!;
                      });
                    },
                  );
                },
              ),
              SizedBox(height: 20), // Add some space between sections
              ElevatedButton(
                onPressed: () async {
                  List<String> selectedTeams = [];
                  List<String> selectedLeagues = [];
                  for (int i = 0; i < teams.length; i++) {
                    if (selectedOptions_teams[i]) {
                      selectedTeams.add(teams[i].name);
                    }
                  }

                  for (int a = 0; a < selectedOptions_leagues.length; a++) {
                    if (selectedOptions_leagues[a]) {
                      selectedLeagues.add(allleagues[a].name);
                    }
                  }

                  print(selectedLeagues);

                  try {
                    await saveSettingsToBackend(selectedTeams, selectedLeagues);
                    Navigator.pop(context);
                  } catch (e) {
                    print('Error: $e');
                  }
                },
                child: Text('Save Settings'),
              ),
              SizedBox(height: 20), // Add some space between sections
            ],
          ),
        ),
      ),
    );
  }
}
