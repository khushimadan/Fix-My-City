import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fix_my_city/screens/full_screen_image.dart';

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
  bool submitted = false;

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
    fetchComplaintDetails();
  }

  Future<void> fetchComplaintDetails() async {
    if (complaintDocId == null || workerId == null) return;

    var doc = await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId)
        .get();

    if (doc.exists && doc.data() != null) {
      var data = doc.data()!;

      Map<String, dynamic> workerImages = data['workerImages'] != null
          ? Map<String, dynamic>.from(data['workerImages'])
          : {};

      Map<String, dynamic> workerFeedback = data['workerFeedback'] != null
          ? Map<String, dynamic>.from(data['workerFeedback'])
          : {};

      bool hasImage = workerImages.containsKey(workerId);
      bool hasFeedback = workerFeedback.containsKey(workerId);

      setState(() {
        submitted = hasImage || hasFeedback;
      });

      debugPrint("Worker ID: $workerId, Has Image: $hasImage, Has Feedback: $hasFeedback, Submitted: $submitted");
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
      String fileName =
          "${workerId}_${DateTime.now().millisecondsSinceEpoch}.jpg";

      // Store in "completed_work_images" folder
      Reference storageRef = FirebaseStorage.instance
          .ref()
          .child("completed_work_images/$fileName");

      UploadTask uploadTask = storageRef.putFile(File(_selectedImage!.path));

      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      } else {
        showAlert("Work completed image upload failed. Try again.");
        return null;
      }
    } catch (e) {
      showAlert("Error: $e");
      return null;
    }
  }

  // Show Alert Dialog with Better UI
  void showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Alert", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(message, style: const TextStyle(fontSize: 16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

// Show Loading Dialog with a Modern Look
  void showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(message, style: const TextStyle(fontSize: 16)),
            ],
          ),
        );
      },
    );
  }

// Show Success Bottom Sheet
  void showSuccessBottomSheet(String message) {
    submitted = true;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.green.shade700,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 28),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context);
    });
  }

// Submit Feedback with Updated Success UI
  Future<void> submitFeedback() async {
    if (complaintDocId == null || workerId == null) return;

    String feedback = feedbackController.text.trim();
    if (feedback.isEmpty || _selectedImage == null) {
      showAlert("Please give feedback and upload an image.");
      return;
    }

    showLoadingDialog("Submitting...");

    String? imageUrl = await uploadImage();

    if (imageUrl == null) {
      Navigator.pop(context);
      showAlert("Image upload failed. Please try again.");
      return;
    }

    Map<String, dynamic> updateData = {
      'workerFeedback.$workerId': feedback,
      'workerImages.$workerId': imageUrl,
    };

    try {
      await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintDocId)
          .update(updateData);

      setState(() {
        _selectedImage = null;
        feedbackController.clear();
      });

      Navigator.pop(context);
      showSuccessBottomSheet("Submitted successfully!");
    } catch (e) {
      Navigator.pop(context);
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: ListView(children: [
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FullScreenImage(
                              imagePath:
                                  widget.data['imageUrl'], // Pass network URL
                              isNetwork: true, // Indicate it's a network image
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
                  Text("Address: ${widget.data['address']}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text("Description: ${widget.data['description']}",
                      style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  if (submitted == true) ...[
                    const Center(
                      child: Text(
                        "Waiting for Admin Approval",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red),
                      ),
                    ),
                  ] else ...[
                    // Image Picker Button
                    ElevatedButton.icon(
                      onPressed: showImagePickerOptions,
                      icon: const Icon(Icons.upload_file),
                      label: const Text("Upload Photo"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),

                    if (_selectedImage != null)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FullScreenImage(
                                imagePath: _selectedImage!
                                    .path, // Pass local image path
                                isNetwork: false, // Indicate it's a local image
                              ),
                            ),
                          );
                        },
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: 250,
                        ),
                      ),

                    const SizedBox(height: 15),
                    const Text("Feedback",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        textStyle: const TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: isUploading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Submit"),
                    ),
                  ]
                ]),
              ));
  }
}
