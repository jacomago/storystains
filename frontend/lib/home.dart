import 'package:flutter/material.dart';
import 'package:storystains/user/login.dart';
import 'package:storystains/user/signup.dart';

import 'http_client.dart';

final navs = [
  Nav(
      name: "Sign up",
      route: '/signup',
      builder: (context) => SignupHttpPage(
            httpClient: client,
          )),
  Nav(
      name: "Log in",
      route: '/login',
      builder: (context) => LoginHttpPage(
            httpClient: client,
          )),
];

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pages'),
      ),
      body: ListView(
        children: [...navs.map((d) => NavTile(nav: d))],
      ),
    );
  }
}

class NavTile extends StatelessWidget {
  final Nav? nav;

  const NavTile({this.nav, super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(nav!.name),
      onTap: () {
        Navigator.pushNamed(context, nav!.route);
      },
    );
  }
}

class Nav {
  final String name;
  final String route;
  final WidgetBuilder builder;

  const Nav({required this.name, required this.route, required this.builder});
}
