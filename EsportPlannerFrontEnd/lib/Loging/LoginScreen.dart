import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Widgets/Objects/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_ma/Widgets/Homepage/MyHomePage.dart';
import 'package:http/http.dart' as http;
import '/Widgets/Objects/Users.dart';
import '../Data/Loader.dart';
import '/Widgets/Objects/TeamInfo.dart';
import '/Widgets/Homepage/MyHomePage.dart';

Loader loader = Loader();
Users users = Users('','','','');
TeamInfo teamInfo = TeamInfo('name', '','','', '', '', '', 'league', 'series', 'leagueurl',DateTime.utc(1900), '', '','', '');
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


//Get the users from the database
Future<void> fetchUsers() async {
 print('Benutzerliste:');
    _users = await loader.fetchUsers();
    print('Benutzerliste:');
    _users.forEach((user) {
      print(user.username);
    });
    setState(() {});
  }


//Login the user
//Check if the entered username is in the list of users
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

//Build the login form
  @override
  Widget build(BuildContext context) {
     bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 200),
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
            SizedBox(height: 20),
            if (!isKeyboardVisible)
            ElevatedButton(
              onPressed: loginUser,
              child: Text('Anmelden'),
            ),
            if (!isKeyboardVisible)
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
