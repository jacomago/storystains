import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:storystains/http_client.dart';

import 'model.dart';

class LoginHttpPage extends StatefulWidget {
  final http.Client? httpClient;
  final Cookie? cookie;

  const LoginHttpPage({
    this.httpClient,
    this.cookie,
    super.key,
  });

  @override
  State<LoginHttpPage> createState() => _LoginHttpPageState();
}

class _LoginHttpPageState extends State<LoginHttpPage> {
  FormData formData = FormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Form'),
      ),
      body: Form(
        child: Scrollbar(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...[
                  TextFormField(
                    autofocus: true,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      filled: true,
                      hintText: 'Your username',
                      labelText: 'Username',
                    ),
                    onChanged: (value) {
                      formData.user.username = value;
                    },
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                      filled: true,
                      labelText: 'Password',
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      formData.user.password = value;
                    },
                  ),
                  TextButton(
                    child: const Text('Login'),
                    onPressed: () async {
                      // Use a JSON encoded string to send
                      var result = await widget.httpClient!.post(
                          local('/login'),
                          body: json.encode(formData.toJson()),
                          headers: {'content-type': 'application/json'});

                      if (result.statusCode == 200) {
                        _showDialog('Successfully logged in.');
                      } else if (result.statusCode == 401) {
                        _showDialog('Unable to log in.');
                      } else {
                        _showDialog('Something went wrong. Please try again.');
                      }
                    },
                  ),
                ].expand(
                  (widget) => [
                    widget,
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
