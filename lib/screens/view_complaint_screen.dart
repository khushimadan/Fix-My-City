import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ViewComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const ViewComplaintScreen({super.key, required this.data});

  @override
  State<ViewComplaintScreen> createState() => _ViewComplaintScreenState();
}

class _ViewComplaintScreenState extends State<ViewComplaintScreen> {
  String? complaintDocId;
  String? workerId;
  TextEditingController feedbackController = TextEditingController();
  File? _selectedImage;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    fetchLoggedInWorker();
    fetchComplaintDocId();
  }

  // Get logged-in worker ID
  void fetchLoggedInWorker() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        workerId = user.uid;
      });
    }
  }

  // Fetch complaint document ID from Firestore
  Future<void> fetchComplaintDocId() async {
    var query = await FirebaseFirestore.instance
        .collection('complaints')
        .where('complaintNo', isEqualTo: widget.data['complaintNo'])
        .get();

    if (query.docs.isNotEmpty) {
      setState(() {
        complaintDocId = query.docs.first.id;
      });
    }
  }

  // Show Image Picker Options
  void showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Pick Image from Camera or Gallery
  Future<void> pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }


  // Upload Image to Firebase Storage
  Future<String?> uploadImage() async {
    if (_selectedImage == null) {
      showAlert("No image selected");
      return null;
    }

    try {
      String fileName = "${workerId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Store in "completed_work_images" folder
      Reference storageRef = FirebaseStorage.instance.ref().child("completed_work_images/$fileName");

      UploadTask uploadTask = storageRef.putFile(File(_selectedImage!.path));

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("Work completed image uploaded: $downloadUrl");
        return downloadUrl;
      } else {
        print("Upload failed: ${snapshot.state}");
        showAlert("Work completed image upload failed. Try again.");
        return null;
      }
    } catch (e) {
      print("Error uploading work completed image: $e");
      showAlert("Error: $e");
      return null;
    }
  }



  // Show Alert Dialog
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Missing Information"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  // Submit Feedback and Image to Firestore
  Future<void> submitFeedback() async {
    if (complaintDocId == null || workerId == null) return;

    String feedback = feedbackController.text.trim();
    if (feedback.isEmpty || _selectedImage == null) {
      showAlert("Please give feedback and upload an image");
      return;
    }

    setState(() {
      isUploading = true;
    });

    String? imageUrl = await uploadImage(); // Upload image and get URL

    if (imageUrl == null) {
      setState(() {
        isUploading = false;
      });
      showAlert("Image upload failed. Please try again.");
      return;
    }

    Map<String, dynamic> updateData = {
      'workerFeedback.$workerId': feedback,
      'workerImages.$workerId': imageUrl,
    };

    try {
      // Update Firestore
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintDocId)
          .update(updateData);

      setState(() {
        isUploading = false;
        _selectedImage = null;
        feedbackController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Feedback and Image submitted successfully")),
      );
    } catch (e) {
      setState(() {
        isUploading = false;
      });
      print("Error updating Firestore: $e");
      showAlert("Failed to submit feedback. Please try again.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF009944),
        title: const Text("View Complaint",
            style: TextStyle(fontFamily: 'Poppins', fontSize: 24)),
        centerTitle: true,
      ),
      body: complaintDocId == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FullScreenImage(
                          imageUrl: widget.data['imageUrl']),
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
            Text("Address: ${widget.data['address']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Description: ${widget.data['description']}",
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            // Image Picker Button
            ElevatedButton.icon(
              onPressed: showImagePickerOptions,
              icon: const Icon(Icons.upload_file),
              label: const Text("Upload Photo"),
            ),

            if (_selectedImage != null)
              GestureDetector(
                child: Image.file(_selectedImage!,
                    height: 200, width: double.infinity, fit: BoxFit.cover),
              ),

            const SizedBox(height: 15),
            const Text("Feedback",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: "Enter Feedback",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            // Submit Button
            ElevatedButton(
              onPressed: isUploading ? null : submitFeedback,
              child: isUploading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}

// Full-Screen Image View
class FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
