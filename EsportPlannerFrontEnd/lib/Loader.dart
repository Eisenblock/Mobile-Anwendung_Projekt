import 'dart:convert';
import 'package:http/http.dart' as http;
import 'past_matches.dart';
import 'TeamInfo.dart';
import 'Users.dart';
import 'LoL_Leagues.dart';
import 'LoL_Teams.dart';

class Loader {
  Future<List<Users>> fetchUsers() async {
    List<Users> userList = [];
    final response = await http.get(Uri.parse('http://192.168.2.125:3000/user'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic usersData = combinedData['users'];
      
      for (var user in usersData) {
        final String name = user['name'];
        final String username = user['username']; 
        final String password = user['password']; 
        final String id = user['_id'];

        final userObject = Users(name, username, password, id);
        userList.add(userObject);
      }
    }

    return userList;
  }

  Future<List<TeamInfo>> fetchTeamInfosLoL(String id) async {
    List<TeamInfo> teamInfos = [];  
    final response = await http.get(Uri.parse('http://192.168.2.125:3000/user/'+ id +'/upcoming-matches'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic dataLoL = combinedData['lol'];
      final dynamic dataValo = combinedData['valorant'];

      for (var match in dataLoL) {
        // Extracting data for LoL matches
      }

      if (dataValo != null) {
        // Extracting data for Valorant matches
      }
    }

    return teamInfos;
  }

  Future<List<LoL_Leagues>> fetchAllLeaguesLoL() async {
    List<LoL_Leagues> lolLeagues = [];
    final response = await http.get(Uri.parse('http://192.168.2.125:3000/lol/leagues'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic dataLoL_Leagues = combinedData['leagues'];

      for (var league in dataLoL_Leagues) {
        final String name = league['name'];
        final String url = league['image_url'] ?? '';
        final LoL_Leagues lolLeague = LoL_Leagues(name, url);
        lolLeagues.add(lolLeague);
      }
    }

    return lolLeagues;
  }

  Future<List<LoL_Team>> fetchAllTeamsLoL() async {
    List<LoL_Team> teams = [];
    final response = await http.get(Uri.parse('http://192.168.2.125:3000/lol/teams'));

    if (response.statusCode == 200) {
      final dynamic combinedData = json.decode(response.body);
      final dynamic dataLoL_teams = combinedData['teams'];

      for (var league in dataLoL_teams) {
        final String name = league['name'];
        final LoL_Team lolLeague = LoL_Team(name, []);
        teams.add(lolLeague);
      }
    }

    return teams;
  }

  Future<List<PastMatches>> fetchPastMatches(String id) async {
    List<PastMatches> pastMatches = [];

    final response = await http.get(
        Uri.parse('http://192.168.2.125:3000/user/' + id + '/past-matches'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (var matchData in data) {
        final String scheduledAt = matchData['scheduled_at'];
        final String name = matchData['name'];
        final String leagueName = matchData['league']['name'];
        final String leagueImageUrl = matchData['league']['image_url'] ?? '';
        final String seriesFullName = matchData['serie']['full_name'] ?? '';
        final int numberOfGames = matchData['number_of_games'];
        final String streamEmbedUrl = matchData['streams_list'][0]['embed_url'];
        final String tournamentName = matchData['tournament']['name'];
        final String tournamentPrizepool =
            matchData['tournament']['prizepool'];
        final String videogameName = matchData['videogame']['name'];

        final PastMatches pastMatch = PastMatches(
          scheduledAt,
          name,
          leagueName,
          leagueImageUrl,
          seriesFullName,
          numberOfGames,
          streamEmbedUrl,
          tournamentName,
          tournamentPrizepool,
          videogameName,
          '',
        );

        pastMatches.add(pastMatch);
      }
    }

    return pastMatches;
  }
}
