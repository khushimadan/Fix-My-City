import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ViewComplaintScreen({super.key, required this.data});

  @override
  State<ViewComplaintScreen> createState() => _ViewComplaintScreenState();
}

class _ViewComplaintScreenState extends State<ViewComplaintScreen> {
  String? complaintDocId;

  @override
  void initState() {
    super.initState();
    fetchComplaintDocId();
  }

  Future<void> fetchComplaintDocId() async {
    var query = await FirebaseFirestore.instance
        .collection('complaints')
        .where('complaintNo', isEqualTo: widget.data['complaintNo'])
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        complaintDocId = query.docs.first.id;
      });

      await fetchComplaintDetails();
    }
  }

  Future<void> fetchComplaintDetails() async {
    if (complaintDocId == null) return;

    var doc = await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId)
        .get();

    if (doc.exists && doc.data() != null) {
      var data = doc.data()!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.white,
          backgroundColor: const Color(0xFF009944),
          title: const Text(
            "View Complaint",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
          ),
          centerTitle: true,
        ),
        body: complaintDocId == null
            ? const Center(child: CircularProgressIndicator())
            : Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: widget.data['imageUrl'],
                        ),
                      ),
                    );
                  },
                  child: Image.network(
                    widget.data['imageUrl'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 250,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Address: ${widget.data['address']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                "Description: ${widget.data['description']}",
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20)
            ],
          ),
        ));
  }
}

// New Screen to Display Full-Size Image
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true, // Allow panning
          minScale: 0.5,
          maxScale: 4.0, // Zoom in up to 4x
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
