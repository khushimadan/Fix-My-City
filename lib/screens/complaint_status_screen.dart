import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComplaintStatusScreen extends StatelessWidget {
  const ComplaintStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in to see complaints.")),
      );
    }

    print("Logged-in user ID: ${user.uid}"); // Debugging

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Complaint Status",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
          ),
          backgroundColor: const Color(0xFF009944),
          foregroundColor: Colors.white,
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: StreamBuilder<QuerySnapshot>(
            stream: _fetchAllComplaints(user.uid), // Using StreamBuilder
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return Center(
                  child: Text(
                    "No complaints found",
                    style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                  ),
                );
              }

              final complaints = snapshot.data!.docs;

              print("Fetched ${complaints.length} complaints"); // Debugging

              return ListView.builder(
                itemCount: complaints.length,
                itemBuilder: (context, index) {
                  var complaint = complaints[index].data() as Map<String, dynamic>;

                  return _buildComplaintItem(
                    complaint["complaintNo"]?.toString() ?? "N/A",
                    complaint["address"] ?? "Unknown Location",
                    complaint["description"] ?? "No Description",
                    complaint["status"] ?? "Unknown Status",
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Fetch complaints for the logged-in user in real-time
  Stream<QuerySnapshot> _fetchAllComplaints(String userId) {
    return FirebaseFirestore.instance
        .collection('complaints')
        .where("userId", isEqualTo: userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Widget _buildComplaintItem(String complaintNo, String location, String issue, String status) {
    return Card(
      child: ListTile(
        title: Text("Complaint No - $complaintNo"),
        subtitle: Text("Location: $location\nIssue: $issue"),
        trailing: Chip(
          label: Text(
            status,
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: status == "Pending" ? Colors.red.shade400 : Colors.green.shade400,
        ),
      ),
    );
  }
}
