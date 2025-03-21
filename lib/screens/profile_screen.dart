import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String email = "Loading...";
  String phone = "Loading...";
  String username = "User";
  String profileImageUrl = "";
  bool isNotificationsEnabled = false;
  bool isLoading = true;

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
            email = userDoc["email"] ?? "No Email";
            phone = userDoc["phone"] ?? "No Phone Number";
            username = userDoc["username"] ?? "User";
            profileImageUrl = userDoc["profileImageUrl"] ?? "";
            isNotificationsEnabled = userDoc["notificationsEnabled"] ?? false;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
          });
        }
      } catch (e) {
        print("Error fetching user data: $e");
        setState(() {
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> editUsername() async {
    TextEditingController nameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Name"),
          content: TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: "Enter your name",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newName = nameController.text.trim();
                if (newName.isNotEmpty) {
                  await updateUsername(newName);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUsername(String name) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          "username": name,
        }, SetOptions(merge: true)); // Ensure it merges with existing data

        setState(() {
          username = name;
        });
      } catch (e) {
        print("Error updating username: $e");
      }
    }
  }


  Future<void> editPhoneNumber() async {
    TextEditingController phoneController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Phone Number"),
          content: TextField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: "Enter your phone number",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                String newPhone = phoneController.text.trim();
                if (newPhone.isNotEmpty) {
                  await updatePhoneNumber(newPhone);
                  Navigator.pop(context);
                }
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  Future<void> updatePhoneNumber(String newPhone) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "phone": newPhone,
      });
      setState(() {
        phone = newPhone;
      });
    }
  }

  Future<void> updateNotificationPreference(bool value) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        "notificationsEnabled": value,
      });
      setState(() {
        isNotificationsEnabled = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Account",style:TextStyle(fontSize: 24,fontFamily: 'Poppins'),),
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF009944),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: profileImageUrl.isNotEmpty ? NetworkImage(profileImageUrl) : null,
                child: profileImageUrl.isEmpty
                    ? Icon(Icons.account_circle, size: 60, color: Colors.white)
                    : null,
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(username, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(width: 5),
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.green),
                    onPressed: editUsername,
                  ),
                ],
              ),
              SizedBox(height: 5),
              Text(email, style: TextStyle(fontSize: 16, color: Colors.grey)),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text(phone),
                trailing: IconButton(
                  icon: Icon(Icons.edit, color: Colors.green),
                  onPressed: editPhoneNumber,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.notifications, color: Colors.green),
                title: Text("Push Notifications"),
                trailing: Switch(
                  value: isNotificationsEnabled,
                  onChanged: (value) {
                    updateNotificationPreference(value);
                  },
                ),
              ),
              ListTile(
                leading: Icon(Icons.lock, color: Colors.green),
                title: Text("Privacy Policy"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PrivacyPolicyScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.settings, color: Colors.green),
                title: Text("Settings"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.help, color: Colors.green),
                title: Text("Help Center"),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HelpCenterScreen()));
                },
              ),
              ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text("Log Out"),
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Our Privacy Policy", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Text("1. Data Collection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("We collect minimal personal data required for app functionality, including email and contact information."),
            SizedBox(height: 10),
            Text("2. Data Protection", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("We implement strong security measures to protect user data from unauthorized access."),
            SizedBox(height: 10),
            Text("3. Third-Party Services", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("We do not share user data with third-party services without user consent."),
            SizedBox(height: 10),
            Text("4. User Control", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("Users can request data deletion at any time through their account settings."),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Accept & Close"),
            ),
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
        padding: EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: Icon(Icons.notifications, color: Colors.green),
              title: Text("Notification Settings"),
              subtitle: Text("Manage your notification preferences"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.security, color: Colors.green),
              title: Text("Account Security"),
              subtitle: Text("Change password, enable 2FA"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.privacy_tip, color: Colors.green),
              title: Text("Privacy Settings"),
              subtitle: Text("Manage your data and privacy settings"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.language, color: Colors.green),
              title: Text("Language"),
              subtitle: Text("Choose your preferred language"),
              onTap: () {},
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.green),
              title: Text("About App"),
              subtitle: Text("Learn more about this application"),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}

class HelpCenterScreen extends StatelessWidget {
  final String phoneNumber = "tel:9971310381"; // Replace with actual number
  final String emailAddress = "mailto:help.fixmycity@gmail.com"; // Email to open in mail app

  void _callNumber() async {
    if (await canLaunch(phoneNumber)) {
      await launch(phoneNumber);
    } else {
      print("Could not launch $phoneNumber");
    }
  }

  void _sendEmail() async {
    if (await canLaunch(emailAddress)) {
      await launch(emailAddress);
    } else {
      print("Could not launch $emailAddress");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Help Center")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Icon(Icons.support_agent, size: 80, color: Colors.green),
                  SizedBox(height: 10),
                  Text(
                    "Need Help? We're here for you!",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.phone, color: Colors.green),
                title: Text("Call Us"),
                subtitle: Text("XXXXXX678326"),
                onTap: _callNumber, // Calls the phone number
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Icon(Icons.email, color: Colors.green),
                title: Text("Email Us"),
                subtitle: Text("help.fixmycity@gmail.com"),
                onTap: _sendEmail, // Opens email app
              ),
            ),
          ],
        ),
      ),
    );
  }
}
