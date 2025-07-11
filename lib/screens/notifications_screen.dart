import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in to see notifications.")),
      );
    }
    return PopScope(
        canPop: false,
        child: PopScope(
          canPop: false,
          child: Scaffold(
            appBar: AppBar(
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              backgroundColor: const Color(0xFF009944),
              title: const Text(
                "Notifications",
                style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
              ),
              centerTitle: true,
              elevation: 0,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("notifications")
                    .where("userId", isEqualTo: user.uid)
                    .orderBy("timestamp", descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No notifications yet",
                        style: TextStyle(fontSize: 18,fontFamily: 'Poppins'),
                      ),
                    );
                  }

                  final notifications = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      var notification = notifications[index];
                      return _buildNotificationItem(
                        notification["message"],
                        notification["timestamp"],
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ));
  }

  /// Notification Card UI
  Widget _buildNotificationItem(String message, Timestamp timestamp) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: ListTile(
        leading: Icon(Icons.notifications, color: const Color(0xFF009944)),
        title: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(_getTimeAgo(timestamp.toDate())), // Convert timestamp to readable time
      ),
    );
  }

  /// Converts Firestore Timestamp to "time ago" format
  String _getTimeAgo(DateTime date) {
    Duration difference = DateTime.now().difference(date);

    if (difference.inMinutes < 1) {
      return "Just now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes}m ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours}h ago";
    } else {
      return "${difference.inDays}d ago";
    }
  }
}