import 'package:fix_my_city/widgets/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

class ComplaintEntryScreen extends StatelessWidget {
  final String problem;
  const ComplaintEntryScreen({super.key, required this.problem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF009944),
        title: Text(problem,
            style: const TextStyle(fontFamily: 'Poppins', fontSize: 24)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text(
                "Upload Image",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.location_on),
              label: const Text(
                "Share Location",
                style: TextStyle(fontFamily: 'Poppins'),
              ),
              onPressed: () {},
            ),
            const SizedBox(height: 10),
            const TextField(
              decoration: InputDecoration(
                labelText: "Address",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 10),
            const TextField(
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Complaint Description",
                labelStyle: TextStyle(fontFamily: 'Poppins'),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const BottomNavBar()));
              },
              child:
                  const Text("Submit", style: TextStyle(fontFamily: 'Poppins')),
            ),
          ],
        ),
      ),
    );
  }
}
