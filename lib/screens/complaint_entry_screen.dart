import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class ComplaintEntryScreen extends StatefulWidget {
  final String problem;
  const ComplaintEntryScreen({super.key, required this.problem});

  @override
  ComplaintEntryScreenState createState() => ComplaintEntryScreenState();
}

class ComplaintEntryScreenState extends State<ComplaintEntryScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Function to Pick Image (Camera or Gallery)**
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// **Show Image Picker Options (Camera / Gallery)**
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt),
            title: Text("Take a Photo"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            },
          ),
          ListTile(
            leading: Icon(Icons.image),
            title: Text("Choose from Gallery"),
            onTap: () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }

  /// **Function to Upload Image to Firebase Storage**
  Future<String?> _uploadImage(File imageFile) async {
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('complaint_images/$fileName.jpg');
      UploadTask uploadTask = ref.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  /// **Function to Get User Location**
  Future<GeoPoint?> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return null;
    }

    // Request permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get user location
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return GeoPoint(position.latitude, position.longitude);
  }

  /// **Function to Submit Complaint to Firestore**
  Future<void> _submitComplaint() async {
    String address = _addressController.text.trim();
    String description = _descriptionController.text.trim();

    if (address.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      String? imageUrl;
      if (_selectedImage != null) {
        imageUrl = await _uploadImage(_selectedImage!);
      }

      GeoPoint? userLocation = await _getUserLocation();
      if (userLocation == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not fetch location")),
        );
        setState(() {
          _isSubmitting = false;
        });
        return;
      }

      // **Generate a Unique Complaint Number**
      int complaintNumber = DateTime.now().millisecondsSinceEpoch;

      // **Choose Firestore Collection based on Complaint Type**
      String collectionName = "";
      switch (widget.problem.toLowerCase()) {
        case "stray dogs":
          collectionName = "stray_dogs";
          break;
        case "garbage collection":
          collectionName = "garbage";
          break;
        case "street light":
          collectionName = "street_lights";
          break;
        case "water logging":
          collectionName = "water_logging";
          break;
        default:
          collectionName = "other_complaints";
      }

      // **Store Complaint in Firestore**
      await FirebaseFirestore.instance.collection(collectionName).add({
        "userId": FirebaseAuth.instance.currentUser?.uid,
        "complaintNo": complaintNumber,
        "address": address,
        "description": description,
        "imageUrl": imageUrl ?? "",
        "location": userLocation,
        "status": "Pending",
        "timestamp": FieldValue.serverTimestamp(),
      });

      // **Store Notification in Firestore**
      await FirebaseFirestore.instance.collection("notifications").add({
        "userId": FirebaseAuth.instance.currentUser?.uid,
        "message": "Your complaint No-$complaintNumber has been submitted successfully.",
        "timestamp": FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Complaint Submitted Successfully!"),backgroundColor: Colors.green.shade400,),
      );

      _addressController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
        _isSubmitting = false;
      });

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error submitting complaint. Try again.")),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.problem,
        style: TextStyle(fontFamily: 'Poppins',fontSize: 24)),
        backgroundColor: const Color(0xFF009944),
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Image Button
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.camera_alt),
                label: Text("Upload Image"),
                onPressed: _showImagePickerOptions,
              ),
            ),
            const SizedBox(height: 15),

            // Image Preview
            if (_selectedImage != null)
              Center(
                child: Image.file(_selectedImage!, height: 150),
              ),
            const SizedBox(height: 20),

            // Address Field
            TextField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: "Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            // Description Field
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: "Complaint Description",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: _submitComplaint,
                child: Text("Submit"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
