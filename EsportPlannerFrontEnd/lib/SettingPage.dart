import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'user_model.dart';
import 'LoL_Leagues.dart';
import 'loader.dart';
import 'LoL_Teams.dart';
import 'AdvanceSettingPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<String> settingsOptions = ['lol', 'valorant'];
  String selectedLeague = '';
  List<LoL_Team> teams = [];
  Loader loader = Loader();
  List<LoL_Leagues> leagues = [];
  List<bool> selectedOptions = [false, false, false];
  List<bool> selectedOptions_leagues = [];
  List<bool> selectedOptions_teams = [];
  String id = '';

  initState() {
    super.initState();
    fetchLeagues().then((_) {
    setState(() {
      selectedOptions_leagues = List<bool>.generate(leagues.length, (index) => false);
     
    });
  });
    
    
  }

Future<void> fetchLeagues() async {
    List<LoL_Leagues> _leagues = [];
    _leagues = await loader.fetchAllLeagues();
   
    setState(() {
      leagues = _leagues;
      
    });
    print(leagues[0].name);
}

Future<void> fetchTeams() async {
    List<LoL_Team> _teams = [];
    _teams = await loader.fetchAllTeamsLoL();
    setState(() {
      teams = _teams;
    });
    print(teams);
}

  Future<void> saveSettingsToBackend(List<String> selectedGames, List<String> selectedLeagues) async {
    final id = Provider.of<UserModel>(context, listen: false).id;
    final url = 'http://192.168.0.44:3000/user/' + id + '' ; // Ersetze dies durch die URL deines Backends

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',      },
      body: jsonEncode(<String, dynamic>{
        
        'selectedGames': selectedGames,
       
      }),
    );

    if (response.statusCode == 201) {
      // Erfolgreiche Anfrage
      print('User data saved successfully');
    } else {
      // Fehler bei der Anfrage
      throw Exception('Failed to save user data');
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
                        SizedBox(height: 20), // Add some space between sections
            ElevatedButton(
              onPressed: () {
                // Hier navigierst du zur Seite "AdvanceSettings", wenn der Button gedrückt wird
                Navigator.push(context, MaterialPageRoute(builder: (context) => AdvanceSettingPage()));
              },
              child: Text('Advanced Settings'),
            ),

            Text('Choose your games:'),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: settingsOptions.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(settingsOptions[index]),
                  value: selectedOptions[index],
                  onChanged: (bool? value) {
                    setState(() {
                      selectedOptions[index] = value!;
                    });
                  },
                );
              },
            ),
           /* SizedBox(height: 20), // Add some space between sections
            Text('Choose your leagues:'),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: leagues.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(leagues[index].name),
                  value: selectedOptions_leagues[index], // Hier könnte eine Korrektur notwendig sein, wenn selectedOptions nicht für die Ligen verwendet werden soll
                  onChanged: (bool? value) {
                    setState(() {
                      selectedOptions_leagues[index] = value!;
                    });
                  },
                );
              },
            ),*/
           
            SizedBox(height: 20), // Add some space between sections
            ElevatedButton(
              onPressed: () async {
                List<String> selectedGames = [];
                List<String> selectedLeagues = [];
                for (int i = 0; i < selectedOptions.length; i++) {
                  if (selectedOptions[i]) {
                    selectedGames.add(settingsOptions[i]);
                  }
                 
                }
                
                for (int a = 0; a < selectedOptions_leagues.length; a++) {
                  if (selectedOptions_leagues[a]) {
                    selectedLeagues.add(leagues[a].name);
                  }
                }

                print(selectedLeagues);

                try {
                  await saveSettingsToBackend(selectedGames,selectedLeagues);
                  Navigator.pop(context);
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Save Settings'),
            ),
          ],
        ),
      ),
    ),
  );
}

}

