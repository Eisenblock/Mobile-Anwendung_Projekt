import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegistrationForm extends StatefulWidget {
  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {

  // IP-Adress of the backend
  String ip_Adress = "10.0.2.2";


  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  List<String> _games = ['lol', 'valorant'];
  List<String> _selectedGames = [];


// Register the user
  Future<void> _register() async {
    print(_selectedGames);
    if (_formKey.currentState!.validate()) {
      final String name = _nameController.text;
      final String username = _usernameController.text;
      final String password = _passwordController.text;

      final Map<String, dynamic> data = {
        'name': name,
        'username': username,
        'password': password,
        'selectedGames': _selectedGames,
      };

      final response = await http.post(
        Uri.parse('http://$ip_Adress:3000/user'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
    }
    Navigator.pushReplacementNamed(context, '/login');
  }


Future<void> getBack() async {
  Navigator.pushReplacementNamed(context, '/login');

}

// Build the registration form
  @override
  Widget build(BuildContext context) {
     bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(   
      appBar: AppBar(title: Text('Registration')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'Username'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                  'Select your Games:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Setzt den Text auf fett gedruckt
                    fontSize: 16.0, // Optional: Setzt die Schriftgröße
                  ),
                ),      
              for (String game in _games)
                CheckboxListTile(
                  title: Text(game),
                  value: _selectedGames.contains(game),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedGames.add(game);
                      } else {
                        _selectedGames.remove(game);
                      }
                    });
                  },
                ),
              SizedBox(height: 20),
               if (!isKeyboardVisible)
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
              if (!isKeyboardVisible)
              ElevatedButton(
                onPressed: getBack,
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


