import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'past_matches.dart';
import 'TeamInfo.dart';
import 'Users.dart';
import 'LoL_Leagues.dart';
import 'LoL_Teams.dart';
import 'Lol_TeamMember.dart';

class Loader {


  String ipAdress ='192.168.2.125';




  Future<List<Users>> fetchUsers() async {
    List<Users> userList = [];
    final response = await http.get(Uri.parse('http://$ipAdress:3000/user'));
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

        final userObject = Users(name, username, password, id);
        userList.add(userObject);
      }
    }

    return userList;
  }





  Future<List<TeamInfo>> fetchTeamInfosLoL(String id) async {
    List<TeamInfo> teamInfos = [];
    final response = await http.get(Uri.parse('http://$ipAdress:3000/user/$id/upcoming-matches'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic dataLoL = combinedData['lol'];
      final dynamic dataValo = combinedData['valorant'];

      for (var match in dataLoL) {
        final String name = match['name'];
        final String timestamp = match['begin_at'];
        final List<String> parts = timestamp.split("T");
        final String date = parts[0];
        final DateTime timeCalender = DateTime.parse(parts[0]);
        final String time = parts[1];
        final String league = match['league'];
        final String leagueurl = match['leagueurl'];
        final String series = match['serie'];
        final List<dynamic> opponents = match['opponents'];
        String opponent1 = '';
        String opponent2 = '';
        String opponent1url = '';
        String opponent2url = '';

        if (opponents.isNotEmpty && opponents.length > 1) {
          opponent1 = opponents[0]['opponent']['name'] ?? "keine Daten";
          opponent2 = opponents[1]['opponent']['name'] ?? "keine Daten";
          opponent1url = opponents[0]['opponent']['image_url'] ?? "keine Daten";
          opponent2url = opponents[1]['opponent']['image_url'] ?? "keine Daten";
        } else {
          opponent1 = "keine Daten";
          opponent2 = "keine Daten";
          opponent1url = "keine Daten";
          opponent2url = "keine Daten";
        }

        print("lOL $opponent1 $opponent2");

        final teamInfo = TeamInfo(name, opponent1, opponent1url, opponent2, opponent2url, date, time, league, series, leagueurl, timeCalender, '');
        teamInfos.add(teamInfo);
      }

      if (dataValo != null) {
        for (var match in dataValo) {
          final String name = match['name'];
          final String timestamp = match['begin_at'];
          final List<String> parts = timestamp.split("T");
          final String date = parts[0];
          final DateTime timeCalender = DateTime.parse(parts[0]);
          final String time = parts[1];
          final String league = match['league'];
          final String leagueurl = match['leagueurl'];
          final String series = match['serie'];
          final List<dynamic> opponents = match['opponents'];
          String opponent1 = '';
          String opponent2 = '';
          String opponent1url = '';
          String opponent2url = '';

          if (opponents.isNotEmpty && opponents.length > 1) {
            opponent1 = opponents[0]['opponent']['name'] ?? "keine Daten";
            opponent2 = opponents[1]['opponent']['name'] ?? "keine Daten";
            opponent1url = opponents[0]['opponent']['image_url'] ?? "keine Daten";
            opponent2url = opponents[1]['opponent']['image_url'] ?? "keine Daten";
          } else {
            opponent1 = "keine Daten";
            opponent2 = "keine Daten";
            opponent1url = "keine Daten";
            opponent2url = "keine Daten";
          }

          print("valo $opponent1 $opponent2");

          final teamInfo = TeamInfo(name, opponent1, opponent1url, opponent2, opponent2url, date, time, league, series, leagueurl, timeCalender, '');
          teamInfos.add(teamInfo);
        }
      }
    }

    return teamInfos;
  }

  Future<List<LoL_Leagues>> fetchAllLeaguesLoL() async {
    List<LoL_Leagues> lolLeagues = [];
    final response = await http.get(Uri.parse('http://$ipAdress:3000/lol/leagues'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic dataLoL_Leagues = combinedData['leagues'];

      for (var league in dataLoL_Leagues) {
        final String name = league['name'];
        String url = league['image_url'] ?? "keine Daten";
        final LoL_Leagues lolLeague = LoL_Leagues(name, url);
        lolLeagues.add(lolLeague);
      }
    }

    return lolLeagues;
  }

Future<List<LoL_Team>> fetchAllTeamsLoL() async {
  List<LoL_Team> teams = [];
  final response = await http.get(Uri.parse('http://$ipAdress:3000/lol/teams'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);
    final List<dynamic> dataLoL_teams = combinedData['teams'];
  
    int i = 0;

    // Durchlaufe alle Teams
  for (var league in combinedData['teams']) {
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

    final LoL_Team lolTeam = LoL_Team(name, teamMembers);
    teams.add(lolTeam);
  }
  } else {
    // Handle error response here
    throw Exception('Failed to load teams');
  }

  return teams;
}

  Future<List<PastMatches>> fetchPastMatches(String id) async {
  List<PastMatches> pastMatchesList = [];
  final response = await http.get(Uri.parse('http://$ipAdress:3000/past-matches'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);

    if (combinedData['lol'] != null) {
      final List<dynamic> matches = combinedData['lol'];

      for (var match in matches) {
        final String name = match['name'] ?? 'Unknown';
       String timestamp = "12:00:00"; // Static value as per original code
        String date = '';
        String begin_at = match['begin_at'];
        final String time = '';
        final String serie = match['serie'] ?? 'Unknown';
        final String leagueUrl = match['leagueurl'] ?? 'Unknown';
        final String league = match['league'] ?? 'Unknown';
        final List<dynamic> opponents = match['opponents'] ?? [];
        final List<dynamic> results = match['results'] ?? [];

        String opponent1 = 'keine Daten';
        String opponent2 = 'keine Daten';
        String opponent1url = 'keine Daten';
        String opponent2url = 'keine Daten';
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
          begin_at,
          league,
          leagueUrl,
          opponent1,
          opponent2,
          serie,
          opponent1url,
          opponent2url,
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

}
