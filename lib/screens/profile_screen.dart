import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fix_my_city/screens/login_signup_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  bool isNotificationsEnabled = true; // Default toggle state

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF009944),
          title: const Text("Your Account",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Profile Section
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  child:
                  const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Jatinpreet Singh",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Text(
                  "jatinpreet@gmail.com",
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 20),

                // My Account Section
                _buildCard([
                  _buildListTile(Icons.person, "Personal Information"),
                  _buildListTile(Icons.language, "Language",
                      trailing: const Text("English (US)")),
                  _buildListTile(Icons.lock, "Privacy Policy"),
                  _buildListTile(Icons.settings, "Settings"),
                ]),

                // Notifications Section
                _buildCard([
                  _buildToggleTile(Icons.notifications, "Push Notifications"),
                ]),

                // More Section
                _buildCard([
                  _buildListTile(Icons.help_outline, "Help Center"),
                  _buildListTile(Icons.logout, "Log Out",
                      textColor: Colors.red, onTap: _logout),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper function to create a settings tile
  Widget _buildListTile(IconData icon, String title,
      {Widget? trailing, Color? textColor, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54),
      title: Text(title,
          style: TextStyle(fontSize: 16, color: textColor ?? Colors.black)),
      trailing: trailing,
      onTap: onTap ?? () {},
    );
  }

  // Helper function to create a toggle switch
  Widget _buildToggleTile(IconData icon, String title) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.black54),
      title: Text(title, style: const TextStyle(fontSize: 16)),
      value: isNotificationsEnabled,
      onChanged: (bool value) {
        setState(() {
          isNotificationsEnabled = value;
        });
      },
    );
  }

  // Helper function to create section cards
  Widget _buildCard(List<Widget> children) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: children,
      ),
    );
  }

  Future<void> _logout() async {
    final contextBeforeAsync = context; // Store context before async operation

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false); // Clear login state

    if (!mounted) return; // Check if the widget is still in the widget tree

    Navigator.pushReplacement(
      contextBeforeAsync, // Use the stored context
      MaterialPageRoute(builder: (context) => const LoginSignup()),
    );
  }
}