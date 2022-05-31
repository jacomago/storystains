import 'package:flutter/material.dart';
import 'package:storystains/user/form.dart';

import 'http_client.dart';

final navs = [
  Nav(
      name: "Sign up",
      route: '/signup',
      builder: (context) => UserFormHttpPage(
            httpClient: client,
            title: "Sign Up",
            path: '/signup',
            submitText: 'Sign Up',
          )),
  Nav(
      name: "Log in",
      route: '/login',
      builder: (context) => UserFormHttpPage(
            httpClient: client,
            title: "Log in",
            path: '/login',
            submitText: 'Log in',
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
