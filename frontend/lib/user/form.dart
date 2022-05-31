import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:storystains/http_client.dart';

import 'model.dart';

class UserFormHttpPage extends StatefulWidget {
  final http.Client? httpClient;
  final String path;
  final String title;
  final String submitText;

  const UserFormHttpPage({
    this.httpClient,
    required this.path,
    required this.title,
    required this.submitText,
    super.key,
  });

  @override
  State<UserFormHttpPage> createState() => _UserFormHttpPageState();
}

class _UserFormHttpPageState extends State<UserFormHttpPage> {
  FormData formData = FormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                    child: Text(widget.submitText),
                    onPressed: () async {
                      // Use a JSON encoded string to send
                      var result = await widget.httpClient!.post(
                          local(widget.path),
                          body: json.encode(formData.toJson()),
                          headers: {'content-type': 'application/json'});

                      if (result.statusCode == 200) {
                        _showDialog('Success.');
                      } else if (result.statusCode == 401) {
                        _showDialog('Invalid Input.');
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
