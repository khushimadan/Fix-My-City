import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String email = "Loading...";
  String phone = "Loading...";
  String username = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (userDoc.exists) {
          setState(() {
            email = userDoc.data() != null && userDoc["email"] != null ? userDoc["email"] : "No Email";
            username = userDoc.data() != null && userDoc["name"] != null ? userDoc["name"] : "No Name";
            phone = userDoc.data() != null && userDoc["phone"] != null ? userDoc["phone"] : "No Phone Number";
            profileImageUrl = userDoc.data() != null && userDoc["profileImageUrl"] != null
                ? userDoc["profileImageUrl"]
                : "";
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
      }
    }
  }

  Future<void> updateUsername(String newUsername) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'name': newUsername,
        });
        setState(() {
          username = newUsername;
        });
      } catch (e) {
        print("Error updating username: $e");
      }
    }
  }

  void _showEditUsernameDialog() {
    TextEditingController _usernameController = TextEditingController(text: username);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Username"),
          content: TextField(
            controller: _usernameController,
            decoration: InputDecoration(hintText: "Enter new username"),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                updateUsername(_usernameController.text);
                Navigator.pop(context);
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Account"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            profileImageUrl.isNotEmpty
                ? CircleAvatar(radius: 40, backgroundImage: NetworkImage(profileImageUrl))
                : CircleAvatar(radius: 40, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 40, color: Colors.white)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(
                  icon: Icon(Icons.edit, size: 18),
                  onPressed: _showEditUsernameDialog,
                ),
              ],
            ),
            SizedBox(height: 5),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            _buildMenuTile(context, "Personal Information", Icons.person, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => PersonalInfoScreen(email: email, phone: phone)));
            }),
            _buildMenuTile(context, "Language", Icons.language, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => LanguageSelectionScreen()));
            }),
            _buildMenuTile(context, "Privacy Policy", Icons.privacy_tip, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
            }),
            _buildMenuTile(context, "Settings", Icons.settings, () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
            }),
            _buildMenuTile(context, "Help Center", Icons.help, () {}),
            _buildMenuTile(context, "Log Out", Icons.logout, () {
              FirebaseAuth.instance.signOut();
              Navigator.pop(context);
            }, color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, String title, IconData icon, VoidCallback onTap, {Color color = Colors.black54}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(fontSize: 16, color: color)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

class PersonalInfoScreen extends StatelessWidget {
  final String email;
  final String phone;
  PersonalInfoScreen({required this.email, required this.phone});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Personal Information")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: $email", style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Phone: $phone", style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}

class LanguageSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Select Language")),
      body: ListView(
        children: [
          ListTile(title: Text("English"), onTap: () {}),
          ListTile(title: Text("Hindi"), onTap: () {}),
        ],
      ),
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Privacy Policy")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text("Here are the rules and regulations of this app..."),
      ),
    );
  }
}

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: ListView(
        children: [
          ListTile(title: Text("Notification Settings"), onTap: () {}),
          ListTile(title: Text("Account Security"), onTap: () {}),
        ],
      ),
    );
  }
}