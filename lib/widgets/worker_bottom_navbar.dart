import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/worker_home_screen.dart';
import 'package:fix_my_city/screens/complaint_status_screen.dart';
import 'package:fix_my_city/screens/notifications_screen.dart';
import 'package:fix_my_city/screens/user_profile_screen.dart';

class WorkerBottomNavBar extends StatefulWidget {
  const WorkerBottomNavBar({super.key});

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<WorkerBottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WorkerHomeScreen(),
    const ComplaintStatusScreen(),
    const NotificationsScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Status'),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}