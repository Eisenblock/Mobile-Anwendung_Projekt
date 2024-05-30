  import 'package:flutter/material.dart';

  class MyStatistik extends StatelessWidget {
    final String title;

    const MyStatistik({Key? key, required this.title}) : super(key: key);

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/route3');
                },
                child: Text('Button 881'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/route4');
                },
                child: Text('Button 2'),
              ),
            ],
          ),
        ),
      );
    }
  }
