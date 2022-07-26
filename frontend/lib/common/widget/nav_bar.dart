import 'package:flutter/material.dart';

/// navigation bar for scaffold
class NavBar extends StatelessWidget {
  /// constructor for navbar
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'My Reviews',
          ),
        ],
      );
}
