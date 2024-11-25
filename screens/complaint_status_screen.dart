import 'package:flutter/material.dart';

class ComplaintStatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          'Complaint Status',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                labelText: "Search by Complaint Number",
                labelStyle: TextStyle(fontSize: 16.0),
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 20.0),

            // Complaint Cards
            Expanded(
              child: ListView(
                children: [
                  ComplaintCard(
                    complaintNo: "XXXXXX",
                    status: "Pending",
                    statusColor: Colors.brown,
                    userName: "Avneet Singh",
                    address: "B2 - 156, MUJ, Jaipur - 303007",
                    issue: "Garbage Collection",
                    date: "24/11/2024",
                  ),
                  SizedBox(height: 10.0),
                  ComplaintCard(
                    complaintNo: "XXXXXX",
                    status: "Resolved",
                    statusColor: Colors.green,
                    userName: "Khushi Madan",
                    address: "G6, MUJ, Jaipur - 303007",
                    issue: "Water logging",
                    date: "26/11/2024",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '',
          ),
        ],
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}

class ComplaintCard extends StatelessWidget {
  final String complaintNo;
  final String status;
  final Color statusColor;
  final String userName;
  final String address;
  final String issue;
  final String date;

  const ComplaintCard({
    Key? key,
    required this.complaintNo,
    required this.status,
    required this.statusColor,
    required this.userName,
    required this.address,
    required this.issue,
    required this.date,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Complaint No - $complaintNo",
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Icon(Icons.person, color: Colors.grey),
                SizedBox(width: 8.0),
                Text(userName),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey),
                SizedBox(width: 8.0),
                Expanded(child: Text(address)),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.report_problem, color: Colors.grey),
                SizedBox(width: 8.0),
                Text(issue),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey),
                SizedBox(width: 8.0),
                Text(date),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ComplaintStatusScreen(),
    ));
