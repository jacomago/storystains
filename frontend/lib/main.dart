import 'package:flutter/material.dart';
import 'package:storystains/home.dart';

void main() => runApp(const StoryStainsApp());

class StoryStainsApp extends StatelessWidget {
  const StoryStainsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Samples',
      theme: ThemeData(primarySwatch: Colors.teal),
      routes: Map.fromEntries(navs.map((d) => MapEntry(d.route, d.builder))),
      home: const HomePage(),
    );
  }
}
