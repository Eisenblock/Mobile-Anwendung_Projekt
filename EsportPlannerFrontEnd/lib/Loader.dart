import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/LoL_Teams.dart';
import 'package:flutter_application_ma/MyHomePage.dart';
import 'package:http/http.dart' as http;
import 'TeamInfo.dart';
import 'Users.dart';
import 'LoL_Leagues.dart';
import 'past_matches.dart';
import 'LoL_TeamMember.dart';

class Loader{

String ip_Adress = "";

 Future<List<Users>> fetchUsers() async {
  List<Users> userList = [];  // Umbenennung der Variablen, um Verwechslungen zu vermeiden
  final response = await http.get(Uri.parse('http://$ip_Adress:3000/user'));
 print("----------------------User: , -----------------------Password: ");

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);
    final dynamic usersData = combinedData['users'];
    
    for (var user in usersData) {
      final String name = user['name'];
      final String username = user['username']; 
      final String password = user['password']; 
      final String id = user['_id'];
  
      print("----------------------User: $username, -----------------------Password: $password");

      final userObject = Users(name,username, password,id); // Erstellung eines Benutzerobjekts
      userList.add(userObject); // Hinzufügen des Benutzers zur Liste
    }
  }

  return userList; // Rückgabe der Benutzerliste
}


  Future<List<TeamInfo>> fetchTeamInfosLoL(String id) async {
  List<TeamInfo> teamInfos = [];  
  final response = await http.get(Uri.parse('http://$ip_Adress:3000/user/$id/upcoming-matches'));


    final dynamic combinedData = json.decode(response.body);
    
    // Überprüfen, ob der Schlüssel "lol" im combinedData-Objekt vorhanden ist
     
      
      final dynamic dataLoL = combinedData['lol'];
      final dynamic dataValo = combinedData['valorant'];
      
    if(dataLoL != null){
        for (var match in dataLoL) {
          final String name = match['name'];
          final String timestamp = match['begin_at'];
          final List<String> parts = timestamp.split("T");
          final String date = parts[0];
          final DateTime timeCalender = DateTime.parse(timestamp.split('T')[0]);
          final String time = parts[1];
          final String league = match['league'];
          final String leagueurl = match['leagueurl']; // Korrektur des Feldnamens
          final String series = match['serie'];
          final List<dynamic> opponents = match['opponents'];
          String opponent1 = '';
          String opponent2 = '';
          String opponent1url = '';
          String opponent2url = '';

          if(opponents.isNotEmpty && opponents.length > 1 && opponents[0]['opponent']['image_url'] != null && opponents[1]['opponent']['image_url'] != null){
          opponent1 = match['opponents'][0]['opponent']['name'];
          opponent2 = match['opponents'][1]['opponent']['name'];
          opponent1url = match['opponents'][0]['opponent']['image_url'];
          opponent2url = match['opponents'][1]['opponent']['image_url'];
          }else{
          opponent1 = "keine Daten";
          opponent2 = "keine Daten";
          opponent1url = "keine Daten";
          opponent2url = "keine Daten";
          }
          print("lOL" + opponent1 + opponent2);

          final teamInfo = TeamInfo(name,opponent1,opponent1url,opponent2,opponent2url, date,time, league, series, leagueurl,timeCalender, '');
          teamInfos.add(teamInfo);
        }
    }
  if(dataValo != null){
          for (var match in dataValo) {
            List<String> parts = [];
            String date = '';
            DateTime timeCalender = DateTime.now();
            String time = '';
            final String name = match['name'];
            final String timestamp = match['begin_at'] ?? 'Unknown';
            if(timestamp == 'Unknown'){
              continue;

            }
            else
            {           
            parts = timestamp.split("T");
            date = parts[0];
            timeCalender = DateTime.parse(timestamp.split('T')[0]);
            time = parts[1];
            }
           
            final String league = match['league'];
            final String leagueurl = match['leagueurl']; // Korrektur des Feldnamens
            final String series = match['serie'];
            final List<dynamic> opponents = match['opponents'];
            String opponent1 = '';
            String opponent2 = '';
            String opponent1url = '';
            String opponent2url = '';

            
            if(opponents.isNotEmpty && opponents.length > 1 && opponents[0]['opponent']['image_url'] != null && opponents[1]['opponent']['image_url'] != null){
            opponent1 = match['opponents'][0]['opponent']['name'];
            opponent2 = match['opponents'][1]['opponent']['name'];
  
  
            opponent1url = match['opponents'][0]['opponent']['image_url'];
            opponent2url = match['opponents'][1]['opponent']['image_url'];
            }else{
            opponent1 = "keine Daten";
            opponent2 = "keine Daten";
            opponent1url = "keine Daten";
            opponent2url = "keine Daten";
            }
            print("valo" + opponent1 + opponent2);

            final teamInfo = TeamInfo(name,opponent1,opponent1url,opponent2,opponent2url, date,time, league, series, leagueurl,timeCalender, '');
            teamInfos.add(teamInfo);
          }
  }
  
  return teamInfos;
}
 //List<TeamInfo> get teamInfos => teamInfos;

Future<List<PastMatches>> fetchPastMatches(String id) async {
  List<PastMatches> pastMatchesList = [];
  final response = await http.get(Uri.parse('http://$ip_Adress:3000/past-matches'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);

    if (combinedData['lol'] != null) {
      final List<dynamic> matches = combinedData['lol'];

      for (var match in matches) {
        final String name = match['name'] ?? 'Unknown';
        List<String> parts = [];
        String date = '';
        DateTime timeCalender = DateTime.now();
        String time = '';
        final String timestamp = match['begin_at'] ?? 'Unknown';
            if(timestamp == 'Unknown'){
              continue;

            }
            else
            {           
            parts = timestamp.split("T");
            date = parts[0];
            timeCalender = DateTime.parse(timestamp.split('T')[0]);
            time = parts[1];
            }
        
        final String serie = match['serie'] ?? 'Unknown';
        final String leagueUrl = match['leagueurl'] ?? 'Unknown';
        final String league = match['league'] ?? 'Unknown';
        final List<dynamic> opponents = match['opponents'] ?? [];
        final List<dynamic> results = match['results'] ?? [];

        String opponent1 = 'keine Daten';
        String opponent2 = 'keine Daten';
        String opponent1url = 'keine Daten';
        String opponent2url = 'keine Daten';
        String videogame = '';
        String winner1 = 'keine Daten';
        String winner2 = 'keine Daten';

        if (opponents.isNotEmpty && opponents.length > 1) {
          opponent1 = opponents[0]['opponent']['name'] ?? "keine Daten";
          opponent2 = opponents[1]['opponent']['name'] ?? "keine Daten";
          opponent1url = opponents[0]['opponent']['image_url'] ?? "keine Daten";
          opponent2url = opponents[1]['opponent']['image_url'] ?? "keine Daten";
        }

        if (results.isNotEmpty && results.length > 1) {
          winner1 = results[0]['score'].toString() ?? "keine Daten";
          winner2 = results[1]['score'].toString() ?? "keine Daten";
        }

        final pastMatch = PastMatches(
          name,
          time,
          date,
          "",
          league,
          leagueUrl,
          opponent1,
          opponent2,
          serie,
          opponent1url,
          opponent2url,
          videogame,
          opponents.toString(), // Storing opponents as a string
          winner1,
          winner2,
          '', // Assuming `winner` field is empty as it's not clear from the API
        );

        pastMatchesList.add(pastMatch);
      }
    } else {
      print('No past matches data found.');
    }
  } else {
    throw Exception('Failed to load past matches');
  }

  return pastMatchesList;
}

Future<List<LoL_Leagues>> fetchAllLeagues() async {
  List<LoL_Leagues> lolLeagues  = [];  
  List<LoL_Leagues> valoLeagues  = [];
  List<LoL_Leagues> allLeagues  = [];
  final response = await http.get(Uri.parse('http://$ip_Adress:3000/allGames/leagues'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);      
    final dynamic dataLoL_Leagues = combinedData['lolLeagues'];
    final dynamic dataValo_Leagues = combinedData['valorantLeagues'];
      

        for (var league in dataLoL_Leagues) {
          //final String videoGame = league['videogame'];
          final String name = league['name'];
          String url = '';
          if(league['image_url'] == null){
            url = "keine Daten";
          }else{
            url = league['image_url'];
          }

          
        
          LoL_Leagues lolLeague = LoL_Leagues(name,url,"lol");
          allLeagues.add(lolLeague);
        }

        for(var league in dataValo_Leagues){
          final String name = league['name'];
          String url = '';
          if(league['image_url'] == null){
            url = "keine Daten";
          }else{
            url = league['image_url'];
          }

          //final String videoGame = league['videogame'];
        
          LoL_Leagues valoLeague = LoL_Leagues(name,url,"valorant");
          allLeagues.add(valoLeague);
        }
  

}
  print(allLeagues[0].videoGame);
  return allLeagues;
}

Future<List<LoL_Team>> fetchAllTeamsLoL() async {
  List<LoL_Team> teams = [];
  final response = await http.get(Uri.parse('http://$ip_Adress:3000/allGames/teams'));

  
    final dynamic combinedData = json.decode(response.body);
   

    // Durchlaufe alle Teams
  for (var league in combinedData['lolTeams']) {
    final String name = league['name'];
    List<dynamic> membersDynamic = league['players'];
    List<LoL_TeamMember> teamMembers = [];

    // Debugging-Ausgabe der Team-Daten
    print('Team: $name');
    print('Players: $membersDynamic');

    // Durchlaufe alle Spieler eines Teams
    for (var member in membersDynamic) {
      // Debugging-Ausgabe der Spieler-Daten
      print('Player data: $member');

      String firstName = member['first_name'] ?? 'Unknown'; // Fallback-Wert 'Unknown' bei null
      String lastName = member['last_name'] ?? 'Unknown';   // Fallback-Wert 'Unknown' bei null
      String image_url = member['image_url'] ?? 'Unknown';   // Fallback-Wert 'Unknown' bei null

      // Debugging-Ausgabe der Namen
      print('First Name: $firstName, Last Name: $lastName');

      LoL_TeamMember teamMember = LoL_TeamMember(firstName, lastName,image_url);
      teamMembers.add(teamMember);
    }

    final LoL_Team lolTeam = LoL_Team(name, teamMembers, 'lol');
    teams.add(lolTeam);
  
  }

   for (var league in combinedData['valorantTeams']) {
    final String name = league['name'];
    List<dynamic> membersDynamic = league['players'];
    List<LoL_TeamMember> teamMembers = [];

    // Debugging-Ausgabe der Team-Daten
    print('Team: $name');
    print('Players: $membersDynamic');

    // Durchlaufe alle Spieler eines Teams
    for (var member in membersDynamic) {
      // Debugging-Ausgabe der Spieler-Daten
      print('Player data: $member');

      String firstName = member['first_name'] ?? 'Unknown'; // Fallback-Wert 'Unknown' bei null
      String lastName = member['last_name'] ?? 'Unknown';   // Fallback-Wert 'Unknown' bei null
      String image_url = member['image_url'] ?? 'Unknown';   // Fallback-Wert 'Unknown' bei null

      // Debugging-Ausgabe der Namen
      print('First Name: $firstName, Last Name: $lastName');

      LoL_TeamMember teamMember = LoL_TeamMember(firstName, lastName,image_url);
      teamMembers.add(teamMember);
    }

    final LoL_Team lolTeam = LoL_Team(name, teamMembers, 'lol');
    teams.add(lolTeam);
  
  }

  
  

  return teams;
}

 /* Future<List<LoL_Team>> fetchAllTeamsLoL() async {
    List<LoL_Team> teams  = [];  
    final response = await http.get(Uri.parse('http://$ip_Adress:3000/allGames/teams'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);      
      final dynamic dataLoL_teams = combinedData['lolTeams'];
      final dynamic dataValo_teams = combinedData['valorantTeams'];
        

          for (var league in dataLoL_teams) {
            final String name = league['name'];
            final String videogame = league['videogame'];
             
          
            final LoL_Team lolLeague = LoL_Team(name,[],videogame);
            teams.add(lolLeague);
          }

          for(var league in dataValo_teams){
            final String name = league['name'];
            final String videogame = league['videogame'];
          
            final LoL_Team valoLeague = LoL_Team(name,[],videogame);
            teams.add(valoLeague);
          }
    }

  return teams;
  }*/

}