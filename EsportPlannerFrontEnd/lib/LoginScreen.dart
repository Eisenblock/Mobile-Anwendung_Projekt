import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/MyHomePage.dart';
import 'package:http/http.dart' as http;
import 'Users.dart';
import 'Loader.dart';
import 'TeamInfo.dart';
import 'MyHomePage.dart';

Loader loader = Loader();
Users users = Users('','','','');
TeamInfo teamInfo = TeamInfo('name', '','','', '', '', '', 'league', 'series', 'leagueurl',DateTime.utc(1900), '');
MyHomePage  myHomePage = MyHomePage(title: 'Esport Planner');

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);
  

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginScreen> {
  List<Users> _users = [];
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String id = '';


  Future<void> fetchUsers() async {
 print('Benutzerliste:');
    _users = await loader.fetchUsers();
    print('Benutzerliste:');
    _users.forEach((user) {
      print(user.username);
    });
    setState(() {});
  }

  void loginUser() {
    fetchUsers();
    final enteredUsername = usernameController.text;
    final enteredPassword = passwordController.text;

    // Überprüfe, ob der eingegebene Benutzername in der Liste der Benutzer vorhanden ist
    if (_users.any((user) => user.username == enteredUsername)) {
      // Hier kannst du den Benutzer zur MyHomePage navigieren
      id = _users.firstWhere((user) => user.username == enteredUsername && user.password == enteredPassword).userID;
      //loader.fetchTeamInfosLoL(id);
       Provider.of<UserModel>(context, listen: false).setID(id);
      Navigator.pushReplacementNamed(context, '/MyHomePage');
    } else {
      // Anzeige einer Fehlermeldung bei ungültigen Anmeldeinformationen
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Fehler'),
            content: Text('Ungültige Anmeldeinformationen: ${users.username} '),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

void navigateToRegistration() {
    Navigator.pushReplacementNamed(context, '/anmeldung');
  }

  @override
  void initState() {
    super.initState();
    print('initState called');
    
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(
                labelText: 'Benutzername',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Passwort',
              ),
            ),
            ElevatedButton(
              onPressed: loginUser,
              child: Text('Anmelden'),
            ),
            ElevatedButton(
              onPressed: navigateToRegistration,
              child: Text('Registrieren'),
            ),
          ],
        ),
      ),
    );
  }
}
