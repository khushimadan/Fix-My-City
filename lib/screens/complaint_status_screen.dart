import 'package:flutter/material.dart';

class ComplaintStatusScreen extends StatelessWidget {
  const ComplaintStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      }, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF009944),
          automaticallyImplyLeading: false,
          title: const Text("Complaint Status",
              style: TextStyle(fontFamily: 'Poppins', fontSize: 24)),
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              _buildComplaintItem("Complaint No - 12345", "Pending"),
              _buildComplaintItem("Complaint No - 56789", "Resolved"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintItem(String complaintNumber, String status) {
    return Card(
      child: ListTile(
        title: Text(complaintNumber),
        subtitle: const Text("Location: XYZ Street\nIssue: Garbage Collection"),
        trailing: Chip(
            label: Text(status),
            backgroundColor: status == "Pending"
                ? Colors.red.shade400
                : Colors.green.shade400),
      ),
    );
  }
}
