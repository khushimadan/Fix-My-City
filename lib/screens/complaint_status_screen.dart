import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ComplaintStatusScreen extends StatelessWidget {
  const ComplaintStatusScreen({super.key});

  static const List<String> complaintCategories = [
    "stray_dogs",
    "garbage",
    "street_lights",
    "water_logging"
  ];

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        body: Center(child: Text("Please log in to see complaints.")),
      );
    }
    return PopScope(
        canPop: false,
        child: Scaffold(
      appBar: AppBar(title: Text("Complaint Status",style: TextStyle(fontFamily: 'Poppins', fontSize: 24)), backgroundColor: const Color(0xFF009944),foregroundColor: Colors.white,centerTitle: true,
      automaticallyImplyLeading: false,),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<QuerySnapshot>>(
          future: _fetchAllComplaints(user.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || snapshot.data == null || snapshot.data!.every((qSnap) => qSnap.docs.isEmpty)) {
              return Center(
                child: Text(
                  "No complaints found",
                  style: TextStyle(fontSize: 18, fontFamily: 'Poppins'),
                ),
              );
            }

            final complaints = snapshot.data!.expand((qSnap) => qSnap.docs).toList();

            return ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                var complaint = complaints[index];

                return _buildComplaintItem(
                  complaint["complaintNo"].toString(),
                  complaint["address"],
                  complaint["description"],
                  complaint["status"],
                );
              },
            );
          },
        ),
      ),
    ));
  }

  Future<List<QuerySnapshot>> _fetchAllComplaints(String userId) async {
    return Future.wait(complaintCategories.map((category) =>
        FirebaseFirestore.instance.collection(category)
            .where("userId", isEqualTo: userId)
            .orderBy("timestamp", descending: true)
            .get()
    ));
  }

  Widget _buildComplaintItem(String complaintNo, String location, String issue, String status) {
    return Card(
      child: ListTile(
        title: Text("Complaint No - $complaintNo"),
        subtitle: Text("Location: $location\nIssue: $issue"),
        trailing: Chip(label: Text(status,style: TextStyle(color: Colors.white),), backgroundColor: status == "Pending" ? Colors.red.shade400 : Colors.green.shade400),
      ),
    );
  }
}
