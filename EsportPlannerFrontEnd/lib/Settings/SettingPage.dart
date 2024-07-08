import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '/Widgets/Objects/user_model.dart';
import '/Widgets/Objects/LoL_Leagues.dart';
import '/Data/loader.dart';
import '/Widgets/Objects/LoL_Teams.dart';
import 'AdvanceSettingPage.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {

  //variablen
  List<String> settingsOptions = ['lol', 'valorant', 'csgo'];
  String selectedLeague = '';
  List<LoL_Team> teams = [];
  Loader loader = Loader();
  List<LoL_Leagues> leagues = [];
  List<bool> selectedOptions = [false, false, false];
  List<bool> selectedOptions_leagues = [];
  List<bool> selectedOptions_teams = [];
  String id = '';
  String ip_Adress = "192.168.0.34";

  initState() {
    super.initState();
    fetchLeagues().then((_) {
    setState(() {
      selectedOptions_leagues = List<bool>.generate(leagues.length, (index) => false);
     
    });
  });
    
    
  }

//Get all leagues from the backend
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

//Save the settings to the backend
Future<void> saveSettingsToBackend(List<String> selectedGames, List<String> selectedLeagues) async {
    final id = Provider.of<UserModel>(context, listen: false).id;
    final url = 'http://$ip_Adress:3000/user/$id' ; // Ersetze dies durch die URL deines Backends

    final response = await http.put(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',      },
      body: jsonEncode(<String, dynamic>{
        
        'selectedGames': selectedGames,
       
      }),
    );

    
      print('User data saved successfully');
    
  }


//Build the settings page
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

                
                  await saveSettingsToBackend(selectedGames,selectedLeagues);
                  Navigator.pop(context);
             
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

