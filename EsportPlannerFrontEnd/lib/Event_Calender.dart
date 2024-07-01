

class Event_Calender {
  String title;
  String opponent1;
  String opponent2;
  String opponent1url;
  String opponent2url;
  String time;
  String? imageUrl;

  Event_Calender({
    required this.title,
    required this.opponent1,
    required this.opponent2,
    required this.opponent1url,
    required this.opponent2url,
    required this.time,
    this.imageUrl,
  });
}