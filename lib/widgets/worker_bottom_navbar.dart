import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/worker_home_screen.dart';
import 'package:fix_my_city/screens/complaint_status_screen.dart';
import 'package:fix_my_city/screens/profile_screen.dart';
import 'package:fix_my_city/screens/worker_notification_screen.dart';

class WorkerBottomNavBar extends StatefulWidget {
  final String workerId;

  const WorkerBottomNavBar({super.key, required this.workerId});

  @override
  State<WorkerBottomNavBar> createState() => _WorkerBottomNavBarState();
}

class _WorkerBottomNavBarState extends State<WorkerBottomNavBar> {
  int _selectedIndex = 0;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const WorkerHomeScreen(),
      const ComplaintStatusScreen(),
      WorkerNotificationsScreen(workerId: widget.workerId),
      ProfileScreen(),
    ];
  }

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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Status'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}