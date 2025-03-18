import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fix_my_city/screens/view_complaint_screen.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({super.key});

  @override
  State<WorkerHomeScreen> createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  String? loggedInWorkerId;

  static const LatLng universityLocation = LatLng(26.8437, 75.5657);

  @override
  void initState() {
    super.initState();
    _getLoggedInWorkerId();
  }

  void _getLoggedInWorkerId() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        loggedInWorkerId = user.uid;
      });
      _loadComplaintMarkers();
    }
  }

  void _loadComplaintMarkers() async {
    if (loggedInWorkerId == null) return;

    try {
      QuerySnapshot complaints = await FirebaseFirestore.instance
          .collection('complaints')
          .where('assignedWorkers', arrayContains: loggedInWorkerId)
          .get();

    Set<Marker> newMarkers = _processMarkers(
        complaints.docs.map((doc) => doc.data() as Map<String, dynamic>).toList(),
      );

      setState(() {
        _markers = newMarkers;
      });

      _moveCameraToMarkers(newMarkers);
    } catch (e) {
      print("Error loading markers: $e");
    }
  }

  Set<Marker> _processMarkers(List<Map<String, dynamic>> complaintData) {
    Set<Marker> newMarkers = {};

    for (var data in complaintData) {
      if (data.containsKey('location') && data['location'] is GeoPoint) {
        String status = data['status']?.toString().toLowerCase() ?? '';
        if (status == 'completed') continue;

        GeoPoint location = data['location'] as GeoPoint;

        newMarkers.add(
          Marker(
            markerId: MarkerId(data['id'] ?? UniqueKey().toString()),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(
              title: data['category'] ?? "Unknown",
              snippet: "Status: ${data['status'] ?? 'Pending'}",
              onTap: () => _showComplaintDetails(data),
            ),
          ),
        );
      }
    }
    return newMarkers;
  }

  void _showComplaintDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(data['category'] ?? "Complaint"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                ? FutureBuilder(
              future: precacheImage(NetworkImage(data['imageUrl']), context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Image.network(
                    data['imageUrl'],
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.image_not_supported,
                          size: 50, color: Colors.grey);
                    },
                  );
                } else {
                  return const SizedBox(
                    width: 50,
                    height: 50,
                    child: CircularProgressIndicator(),
                  );
                }
              },
            )
                : const Icon(Icons.image_not_supported,
                size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(data['description'] ?? "No description available"),
            Text("Status: ${data['status'] ?? 'Pending'}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ViewComplaintScreen(data:data)),);}, child: const Text("View Complaint")),
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close")),
        ],
      ),
    );
  }

  Future<void> _moveCameraToMarkers(Set<Marker> markers) async {
    final GoogleMapController controller = await _controller.future;

    if (markers.isNotEmpty) {
      LatLngBounds bounds = _getBoundsFromMarkers(markers);
      await controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(target: universityLocation, zoom: 15),
      ));
    }
  }

  LatLngBounds _getBoundsFromMarkers(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLat = markers.first.position.latitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      minLat = marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat = marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng ? marker.position.longitude : minLng;
      maxLng = marker.position.longitude > maxLng ? marker.position.longitude : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          backgroundColor: const Color(0xFF009944),
          foregroundColor: Colors.white,
          title: const Text("Home", style: TextStyle(fontSize: 24)),
        ),
        body: GoogleMap(
          initialCameraPosition:
          const CameraPosition(target: universityLocation, zoom: 15),
          markers: _markers,
          onMapCreated: (controller) => _controller.complete(controller),
        ),
      ),
    );
  }
}
