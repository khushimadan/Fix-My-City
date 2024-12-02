import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person),
            ),
            const SizedBox(height: 16),
            const Text(
              'Jatinpreet Singh',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              'jatinpreet@gmail.com',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            // Account Information Section
            const Text(
              'My Account',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Personal Information'),
              onTap: () {
                // Handle tap on Personal Information
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: const Text('English (US)'),
              onTap: () {
                // Handle tap on Language
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: const Text('Privacy Policy'),
              onTap: () {
                // Handle tap on Privacy Policy
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                // Handle tap on Settings
              },
            ),
            // Notifications Section
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Push Notifications'),
              trailing: Switch(
                value: true, // Replace with your desired initial value
                onChanged: (value) {
                  // Handle switch toggle
                },
              ),
            ),
            // More Section
            const Text(
              'More',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListTile(
              leading: const Icon(Icons.help_center),
              title: const Text('Help Center'),
              onTap: () {
                // Handle tap on Help Center
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Log Out'),
              onTap: () {
                // Handle tap on Log Out
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Account',
          ),
        ],
        currentIndex: 3, // Set to 3 for Account screen
      ),
    );
  }
}
