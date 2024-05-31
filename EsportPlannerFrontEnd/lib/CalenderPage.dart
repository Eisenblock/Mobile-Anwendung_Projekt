import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'TeamInfo.dart';
import'Loader.dart';
import 'package:provider/provider.dart ';
import 'user_model.dart';

class CalendarPage extends StatefulWidget {
  final String title;

  const CalendarPage({Key? key, required this.title}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  Loader loader = Loader();
  List<TeamInfo> teamInfos = [];
  String id = '';
  final Map<DateTime, List<String>> events = {
    DateTime.now(): ['Meeting at 10 AM', 'Lunch at 12 PM'],
    DateTime.now().add(Duration(days: 1)): ['Gym at 6 AM'],
    DateTime.now().add(Duration(days: 2)): ['Project deadline'],
    DateTime.now().add(Duration(days: 3)): ['Doctor appointment at 5 PM'],
    DateTime.now().add(Duration(days: 4)): ['Team meeting at 2 PM'],
    DateTime.now().add(Duration(days: 5)): ['Birthday party at 7 PM'],
    DateTime.now().add(Duration(days: 6)): ['Grocery shopping at 3 PM'],
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetGameInfo();
  }

 Future<void> GetGameInfo() async {
  try {
    id = Provider.of<UserModel>(context, listen: false).id;
    // Verwende die Beispieldaten
    List<TeamInfo> _teamInfos = await loader.fetchTeamInfosLoL(id);

    // Durchlaufe die Teaminfos und aktualisiere die events-Map
    _teamInfos.forEach((teamInfo) {
      DateTime eventDate = DateTime.parse(teamInfo.date);
      String formattedEventDate = _formatDate(eventDate);

      if (events.containsKey(eventDate)) {
        // Füge den Namen des Teams zu den vorhandenen Events hinzu
        events[eventDate]!.add(teamInfo.name);
      } else {
        // Erstelle eine neue Liste mit dem Namen des Teams unter diesem Datum
        events[eventDate] = [teamInfo.series];
      }
    });
    print(events);

    setState(() {
      teamInfos = _teamInfos;
    });
  } catch (error) {
    print('Fehler beim Laden der Teaminfos: $error');
    // Behandle den Fehler entsprechend
  }
}


@override
Widget build(BuildContext context) {
  // Erstelle eine Liste aller Daten, an denen Ereignisse stattfinden
  List<DateTime> eventDates = [];
  teamInfos.forEach((teamInfo) {
    DateTime eventDate = DateTime.parse(teamInfo.date);
    if (!eventDates.contains(eventDate)) {
      eventDates.add(eventDate);
    }
  });

  return Scaffold(
    appBar: AppBar(
      title: Text('Week View'),
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: eventDates.map((date) {
          String formattedDate = _formatDate(date);
          List<String> dayEvents = [];

          // Füge die Namen der Teams hinzu, die an diesem Tag spielen
          teamInfos.forEach((teamInfo) {
            DateTime eventDate = DateTime.parse(teamInfo.date);
            if (eventDate == date) {
              dayEvents.add(teamInfo.opponent1 + ' vs ' + teamInfo.opponent2);
              dayEvents.add(teamInfo.league);
            }
          });

          return Column(
            children: [
              Container(
                width: 150,
                height: 50,
                margin: EdgeInsets.all(4.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    formattedDate,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Container(
                width: 150,
                height: 200,
                padding: EdgeInsets.all(8.0),
                margin: EdgeInsets.only(bottom: 4.0),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: dayEvents.map((event) {
                    return Text(
                      event,
                      style: TextStyle(color: Colors.black, fontSize: 10),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    ),
  );
}

  String _formatDate(DateTime date) {
    List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];

    String dayOfWeek = weekdays[date.weekday % 7];
    String day = date.day.toString();
    String month = months[date.month - 1];

    return '$dayOfWeek, $day $month';
  }
}


