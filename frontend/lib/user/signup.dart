// Copyright 2020, the Flutter project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../http_client.dart';
import 'model.dart';

class SignupHttpPage extends StatefulWidget {
  final http.Client? httpClient;

  const SignupHttpPage({
    this.httpClient,
    super.key,
  });

  @override
  State<SignupHttpPage> createState() => _SignupHttpPageState();
}

class _SignupHttpPageState extends State<SignupHttpPage> {
  FormData formData = FormData();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign up Form'),
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
                    child: const Text('Sign up'),
                    onPressed: () async {
                      // Use a JSON encoded string to send
                      var result = await widget.httpClient!.post(
                          local('/signup'),
                          body: json.encode(formData.toJson()),
                          headers: {'content-type': 'application/json'});

                      if (result.statusCode == 200) {
                        _showDialog('Successfully signed up.');
                      } else if (result.statusCode == 401) {
                        _showDialog('Unable to sign up.');
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
