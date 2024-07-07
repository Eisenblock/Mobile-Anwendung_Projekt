class TeamInfo {
  final String name;
  final String videoGame;
  final String opponent1;
  final String opponent2;
  final String opponent1url;
  final String opponent2url;
  final String opponent_short1;
  final String opponent_short2;
  final String date;
  final DateTime timeCalender;
  final String time;
  final String league;
  final String series;
  final String leagueurl;
  String userID;


  TeamInfo(this.name,this.opponent1,this.opponent1url,this.opponent2, this.opponent2url, this.date, this.time, this.league, this.series, this.leagueurl,this.timeCalender,this.userID, this.opponent_short1, this.opponent_short2, this.videoGame);
}