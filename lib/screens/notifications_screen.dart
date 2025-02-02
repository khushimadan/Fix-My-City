import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          backgroundColor: const Color(0xFF009944),
          title: const Text("Notifications",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24)),
          centerTitle: true,
          elevation: 0,
        ),
        body: ListView(
          children: const [
            ListTile(
                title: Text("Your complaint No - 12345 has been resolved"),
                subtitle: Text("1m ago")),
            ListTile(
                title: Text("Your complaint No - 12345 is in progress"),
                subtitle: Text("10h ago")),
            ListTile(
                title: Text("Your complaint No - 56789 has been resolved"),
                subtitle: Text("10d ago")),
          ],
        ),
      ),
    );
  }
}