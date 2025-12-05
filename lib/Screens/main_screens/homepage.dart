import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:inkspire/Screens/main_screens/Add_new_post.dart';
import 'package:inkspire/Screens/main_screens/stories.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _selectedIndex = 0;

  // List of pages for each navigation item
  final List<Widget> _pages = [
    Stories(),
    const Center(child: Text('Bookmark Page')),
    const Center(child: Text('Search Page')),
    AddNewPost(),
    const Center(child: Text('Profile Page')),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        backgroundColor: Colors.white,
        color: Colors.grey[200]!,
        buttonBackgroundColor: const Color(0xFF1E90FF),
        height: 60,
        animationDuration: const Duration(milliseconds: 300),
        index: _selectedIndex,
        items: [
          Icon(
            Icons.home,
            size: 30,
            color: _selectedIndex == 0 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.bookmark,
            size: 30,
            color: _selectedIndex == 1 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.search,
            size: 30,
            color: _selectedIndex == 2 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.add_circle,
            size: 30,
            color: _selectedIndex == 3 ? Colors.white : Colors.black,
          ),
          Icon(
            Icons.person,
            size: 30,
            color: _selectedIndex == 4 ? Colors.white : Colors.black,
          ),
        ],
        onTap: _onItemTapped,
      ),
    );
  }
}
