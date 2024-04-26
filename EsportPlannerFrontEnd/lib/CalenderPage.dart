import 'dart:convert';
import 'TeamInfo.dart';
import 'Loader.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;



class CalenderPage extends StatefulWidget {
  final String title;

  const CalenderPage({Key? key, required this.title}) : super(key: key);

  @override
  _CalenderPageState createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  TeamInfo teamInfo = TeamInfo('name', '','','', '', '', '', 'league', 'series', 'leagueurl',DateTime.utc(1900));
  Loader loader = Loader();
  late DateTime _focusedDay;
  late Map<DateTime, List<TeamInfo>> _gamesByDate;
  late ValueNotifier<List<TeamInfo>> _selectedEvents;
  late bool _isWeekView;
  List<TeamInfo> teamInfos = [];

  @override
  void initState() {
    super.initState();
    _gamesByDate = {};
    _focusedDay = DateTime.now();
    _selectedEvents = ValueNotifier([]);
    _isWeekView = false; // Initial ist Monatsansicht aktiviert
    loader.fetchTeamInfosLoL().then((value) {
      setState(() {
        teamInfos = value;
      });
    });
  }



  

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.title),
    ),
    body: Column(
      children: [
        Container(
          margin: EdgeInsets.all(20),
          child: TableCalendar(
            firstDay: DateTime.utc(2022, 1, 1),
            lastDay: DateTime.now().add(Duration(days: 365)), // Dynamisch auf das aktuelle Jahr plus 1 Jahr setzen
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_focusedDay, day);
            },
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            eventLoader: (day) {
              // Spiele für das ausgewählte Datum finden
              List<TeamInfo> games = teamInfos
                .where((game) => isSameDay(game.timeCalender, day))
                .toList();

              List<Map<String, dynamic>> events = [];
              for (var game in games) {
                events.add({
                  'date': game.date,
                  'name': game.name,
                });
              }
              return events;
            },
            calendarFormat: _isWeekView ? CalendarFormat.week : CalendarFormat.month,
            rowHeight: _isWeekView ? 150 : 100, // Erhöhen der Höhe in der Wochenansicht
            daysOfWeekHeight: 40,
            headerVisible: true,
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _isWeekView = !_isWeekView;
            });
          },
          child: Text(_isWeekView ? 'Monatsansicht' : 'Wochenansicht'),
        ),
      ],
    ),
  );
}

}
