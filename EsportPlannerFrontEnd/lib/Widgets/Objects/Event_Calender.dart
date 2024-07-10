

class Event_Calender {
  String name;
  String opponent1;
  String opponent2;
  String opponent1url;
  String opponent2url;
  String time;
  String date;
  String opponent1_short;
  String opponent2_short;
  String? imageUrl;
  String videoGame;

  Event_Calender({
    required this.name,
    required this.opponent1,
    required this.opponent2,
    required this.opponent1url,
    required this.opponent2url,
    required this.time,
    required this.date,
    required this.opponent1_short,
    required this.opponent2_short,
    this.imageUrl,
    required this.videoGame,
  });
}