import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_application_ma/Event_Calender.dart';
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
  final Map<DateTime, List<String>> events = {};
  Map<DateTime, bool> eventsExistence = {};

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    GetGameInfo();
  }

 DateTime firstDate = DateTime.now(); // Frühestes Datum
  DateTime lastDate = DateTime(1900); // Spätestes Datum

Future<void> GetGameInfo() async {
  
    id = Provider.of<UserModel>(context, listen: false).id;
    // Verwende die Beispieldaten
    List<TeamInfo> _teamInfos = await loader.fetchTeamInfosLoL(id);

    // Initialisiere firstDate und lastDate mit extremen Werten
    DateTime earliestDate = DateTime.now();
    DateTime latestDate = DateTime(1900);

    // Durchlaufe die Teaminfos und aktualisiere die events-Map
    _teamInfos.forEach((teamInfo) {
      DateTime eventDate = DateTime.parse(teamInfo.date);

      // Update earliestDate und latestDate
      if (eventDate.isBefore(earliestDate)) {
        earliestDate = eventDate;
      }
      if (eventDate.isAfter(latestDate)) {
        latestDate = eventDate;
      }

      if (events.containsKey(eventDate)) {
        // Füge den Namen des Teams zu den vorhandenen Events hinzu
        events[eventDate]!.add(teamInfo.name);
      } else {
        // Erstelle eine neue Liste mit dem Namen des Teams unter diesem Datum
        events[eventDate] = [teamInfo.series];
      }

       eventsExistence[eventDate] = true;
    });

    // Setze firstDate und lastDate
    firstDate = earliestDate;
    lastDate = latestDate;

     for (DateTime date = firstDate; date.isBefore(lastDate); date = date.add(Duration(days: 1))) {
      if (!eventsExistence.containsKey(date)) {
        // Wenn es keinen Eintrag in eventsExistence für diesen Tag gibt, setze den Wert auf false
        eventsExistence[date] = false;
      }
    }

    print(events);

    setState(() {
      teamInfos = _teamInfos;
    });
  
}

@override
Widget build(BuildContext context) {
  if (firstDate == null || lastDate == null) {
    return Center(child: CircularProgressIndicator());
  }

  List<DateTime> allDates = [];
  for (DateTime date = firstDate!;
      date.isBefore(lastDate!) || date.isAtSameMomentAs(lastDate!);
      date = date.add(Duration(days: 1))) {
    allDates.add(date);
  }

  return Scaffold(
    appBar: AppBar(
      title: Text('Week View'),
    ),
    body: SingleChildScrollView(
      child: Center(
        child: _buildEventWrap(allDates),
      ),
    ),
  );
}

Widget _buildEventWrap(List<DateTime> allDates) {
  return Wrap(
    spacing: 16.0,
    runSpacing: 16.0,
    alignment: WrapAlignment.center,
    children: allDates.map((date) {
      return _buildEventColumn(date);
    }).toList(),
  );
}

Widget _buildEventColumn(DateTime date) {
  String formattedDate = _formatDate(date);
  List<Event_Calender> dayEvents = [];

  teamInfos.forEach((teamInfo) {
    DateTime eventDate = DateTime.parse(teamInfo.date);
    if (eventDate == date) {
      dayEvents.add(Event_Calender(
        name: teamInfo.name,
        opponent1: teamInfo.opponent1,
        opponent2: teamInfo.opponent2,
        opponent1url: teamInfo.opponent1url,
        opponent2url: teamInfo.opponent2url,
        imageUrl: teamInfo.leagueurl,
        time: teamInfo.time,
        date: teamInfo.date,
        opponent1_short : teamInfo.opponent_short1,
        opponent2_short : teamInfo.opponent_short2,
      ));
    }
  });

  return Column(
    children: [
      _buildDateBox(formattedDate),
      _buildEventList(dayEvents),
    ],
  );
}

Widget _buildDateBox(String formattedDate) {
  return Container(
    width: 380,
    height: 30,
    margin: EdgeInsets.all(4.0),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Center(
      child: Text(
        formattedDate,
        style: TextStyle(color: Colors.white, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ),
  );
}

Widget _buildEventList(List<Event_Calender> dayEvents) {
  if (dayEvents.isEmpty) {
    return SizedBox.shrink(); // Zeige nichts an, wenn dayEvents leer ist
  }

  return Container(
    width: 380,
    padding: EdgeInsets.all(8.0),
    margin: EdgeInsets.only(bottom: 4.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(8.0),
    ),
    constraints: BoxConstraints(
      minHeight: 200, // Mindesthöhe
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: dayEvents.map((event) {
        return _buildEventBox(event);
      }).toList(),
    ),
  );
}

Widget _buildEventBox(Event_Calender event) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.0),
    padding: EdgeInsets.all(8.0),
    width: 250,
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(8.0),
    ),
    child: Column(
      children: [
        Text(event.name, style: TextStyle(color: Colors.black, fontSize: 16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                if (event.opponent1url != 'keine Daten')
                  Image.network(
                    event.opponent1url,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                SizedBox(height: 4),
                if(event.opponent1 != 'keine Daten')
                Text(
                  event.opponent1_short,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
            SizedBox(width: 4),   
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25.0), // Padding um den "vs" Text
              child: Text(
                'vs',
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
            ),
            SizedBox(width: 4),
            Column(
              children: [
                if (event.opponent2url != 'keine Daten')
                  Image.network(
                    event.opponent2url,
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                  )
                else
                  Container(
                    height: 40,
                    width: 40,
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: Colors.black),
                    ),
                    child: Center(
                      child: Text(
                        '?',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                SizedBox(height: 4),
                if(event.opponent2 != 'keine Daten')
                Text(
                  event.opponent2_short,
                  style: TextStyle(color: Colors.black, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.access_time, size: 16.0, color: Colors.black),
            SizedBox(width: 4.0),
            Text(
              '${event.time}',
              style: TextStyle(color: Colors.black, fontSize: 12),
            ),
          ],
        ),
      ],
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


