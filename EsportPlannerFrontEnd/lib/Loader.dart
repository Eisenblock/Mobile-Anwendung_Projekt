import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/LoL_Teams.dart';
import 'package:flutter_application_ma/MyHomePage.dart';
import 'package:http/http.dart' as http;
import 'TeamInfo.dart';
import 'Users.dart';
import 'LoL_Leagues.dart';

class Loader{


 Future<List<Users>> fetchUsers() async {
  List<Users> userList = [];  // Umbenennung der Variablen, um Verwechslungen zu vermeiden
  final response = await http.get(Uri.parse('http://192.168.0.44:3000/user'));
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
  final response = await http.get(Uri.parse('http://192.168.0.44:3000/user/'+ id +'/upcoming-matches'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);
    
    // Überprüfen, ob der Schlüssel "lol" im combinedData-Objekt vorhanden ist
     
      
      final dynamic dataLoL = combinedData['lol'];
      final dynamic dataValo = combinedData['valorant'];
      

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

  if(dataValo != null){
          for (var match in dataValo) {
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
            print("valo" + opponent1 + opponent2);

            final teamInfo = TeamInfo(name,opponent1,opponent1url,opponent2,opponent2url, date,time, league, series, leagueurl,timeCalender, '');
            teamInfos.add(teamInfo);
          }
  }
  }
  return teamInfos;
}
 //List<TeamInfo> get teamInfos => teamInfos;

Future<List<LoL_Leagues>> fetchAllLeaguesLoL() async {
  List<LoL_Leagues> lolLeagues  = [];  
  final response = await http.get(Uri.parse('http://192.168.0.44:3000/lol/leagues'));

  if (response.statusCode == 200) {
    final dynamic combinedData = json.decode(response.body);      
    final dynamic dataLoL_Leagues = combinedData['leagues'];
      

        for (var league in dataLoL_Leagues) {
          final String name = league['name'];
          String url = '';
          if(league['image_url'] == null){
            url = "keine Daten";
          }else{
            url = league['image_url'];
          }
        
          final LoL_Leagues lolLeague = LoL_Leagues(name,url);
          lolLeagues.add(lolLeague);
        }
  

}
  return lolLeagues;
}

  Future<List<LoL_Team>> fetchAllTeamsLoL() async {
    List<LoL_Team> teams  = [];  
    final response = await http.get(Uri.parse('http:// 192.168.0.44:3000/lol/teams'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);      
      final dynamic dataLoL_teams = combinedData['teams'];
        

          for (var league in dataLoL_teams) {
            final String name = league['name'];
            

            
          
            final LoL_Team lolLeague = LoL_Team(name,[]);
            teams.add(lolLeague);
          }
    }

  return teams;
  }

}