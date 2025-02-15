import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminProfileScreen extends StatefulWidget {
  @override
  _AdminProfileScreenState createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  String email = "Loading...";
  String username = "Loading...";
  String profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    fetchAdminData();
  }

  Future<void> fetchAdminData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        setState(() {
          email = user.email ?? "No Email";
        });
        DocumentSnapshot adminDoc =
        await FirebaseFirestore.instance.collection('admins').doc(user.uid).get();
        if (adminDoc.exists) {
          setState(() {
            username = adminDoc.data() != null && adminDoc["name"] != null ? adminDoc["name"] : "No Name";
            profileImageUrl = adminDoc.data() != null && adminDoc["profileImageUrl"] != null
                ? adminDoc["profileImageUrl"]
                : "";
          });
        }
      } catch (e) {
        print("Error fetching admin data: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Account"), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            profileImageUrl.isNotEmpty
                ? CircleAvatar(radius: 40, backgroundImage: NetworkImage(profileImageUrl))
                : CircleAvatar(radius: 40, backgroundColor: Colors.grey, child: Icon(Icons.person, size: 40, color: Colors.white)),
            SizedBox(height: 10),
            Text(username, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
            SizedBox(height: 20),
            _buildMenuTile(context, "Admin Information", Icons.person, () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AdminInfoScreen(email: email)));
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

class AdminInfoScreen extends StatelessWidget {
  final String email;
  AdminInfoScreen({required this.email});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Information")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Email: $email", style: TextStyle(fontSize: 18)),
          ],
        ),
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
