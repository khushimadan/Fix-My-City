import 'package:flutter/material.dart';
import 'package:fix_my_city/screens/complaint_entry_screen.dart';

class UserHomeScreen extends StatelessWidget {
  const UserHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF009944),
          automaticallyImplyLeading: false,
          title: const Text(
            "Home",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Reduced Height for Banner Image
              SizedBox(
                width: double.infinity,
                height:
                220, // 🔹 Decreased height to make buttons fully visible
                child: Image.asset(
                  'images/main_screen.png', // Ensure this image exists
                  fit: BoxFit.cover,
                ),
              ),

              const SizedBox(height: 15),

              // Title Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  "SELECT YOUR PROBLEM CATEGORY",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF009944),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Problem Selection Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildProblemButton(
                        context, "Roads and Infrastructure", "images/accident.png"),
                    _buildProblemButton(
                        context, "Sanitation and Waste", "images/dustbin.png"),
                    _buildProblemButton(
                        context, "Water and Utilities", "images/tap_water.png"),
                    _buildProblemButton(
                        context, "Lighting and Public Safety", "images/street-light.png"),
                    _buildProblemButton(
                        context, "Environment and Public Spaces", "images/environment.png"),
                    _buildProblemButton(
                        context, "Other", "images/other.png"),
                  ],
                ),
              ),

              const SizedBox(height: 20), // 🔹 Added spacing at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper function for problem buttons
  Widget _buildProblemButton(
      BuildContext context, String problem, String iconPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ComplaintEntryScreen(problem: problem)),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFF009944), width: 2),
        ),
        elevation: 2,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(iconPath,
                  height: 45),// 🔹 Adjusted icon size
              const SizedBox(height: 6),
              Text(
                problem.toUpperCase(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}