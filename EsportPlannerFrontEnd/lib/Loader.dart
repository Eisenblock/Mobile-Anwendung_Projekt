import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/MyHomePage.dart';
import 'package:http/http.dart' as http;
import 'TeamInfo.dart';

class Loader{


  Future<List<TeamInfo>> fetchTeamInfosLoL() async {
  List<TeamInfo> teamInfos = [];  
  final response = await http.get(Uri.parse('http://192.168.0.34:3000/upcoming-matches'));

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

          final teamInfo = TeamInfo(name,opponent1,opponent1url,opponent2,opponent2url, date,time, league, series, leagueurl,timeCalender);
          teamInfos.add(teamInfo);
        }

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

          final teamInfo = TeamInfo(name,opponent1,opponent1url,opponent2,opponent2url, date,time, league, series, leagueurl,timeCalender);
          teamInfos.add(teamInfo);
        }
        
  }
  return teamInfos;
}
}