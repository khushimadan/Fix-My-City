import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fix_my_city/screens/manage_complaint_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  Set<String> selectedFilters = {}; // Store multiple selected categories

  final List<String> complaintTypes = [
    "Roads and Infrastructure",
    "Sanitation and Waste",
    "Water and Utilities",
    "Lighting and Public Safety",
    "Environment and Public Spaces",
    "Other"
  ];

  static const LatLng universityLocation = LatLng(26.8437, 75.5657);

  @override
  void initState() {
    super.initState();
    _loadComplaintMarkers();
  }

  void _loadComplaintMarkers() async {
    try {
      QuerySnapshot complaints =
          await FirebaseFirestore.instance.collection('complaints').get();

      Set<Marker> newMarkers = _processMarkers(
        complaints.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList(),
      );

      setState(() {
        _markers = newMarkers;
      });

      _moveCameraToMarkers(newMarkers);
    } catch (e) {print("Error loading markers: $e");
    }
  }

  Set<Marker> _processMarkers(List<Map<String, dynamic>> complaintData) {
    Set<Marker> newMarkers = {};

    for (var data in complaintData) {
      if (data.containsKey('location') && data['location'] is GeoPoint) {
        String status = data['status']?.toString().toLowerCase() ?? '';
        if (status == 'completed') continue;

        GeoPoint location = data['location'] as GeoPoint;
        String category = data['category'] ?? "Unknown";

        if (selectedFilters.isNotEmpty && !selectedFilters.contains(category))
          continue;

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
        title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              data['category'] ?? "Complaint",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (data['isCritical'] == true)
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.yellow[700], size: 20),
                SizedBox(width: 4),
                Text(
                  "Critical",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold,fontSize: 20),
                ),
              ],
            ),
        ],
      ),
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
          TextButton(onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => ManageComplaintScreen(data:data)),);}, child: const Text("Manage Complaint")),
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
      minLat =
          marker.position.latitude < minLat ? marker.position.latitude : minLat;
      maxLat =
          marker.position.latitude > maxLat ? marker.position.latitude : maxLat;
      minLng = marker.position.longitude < minLng
          ? marker.position.longitude
          : minLng;
      maxLng = marker.position.longitude > maxLng
          ? marker.position.longitude
          : maxLng;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
  }

  void _toggleFilter(String filter) {
    setState(() {
      if (selectedFilters.contains(filter)) {
        selectedFilters.remove(filter);
      } else {
        selectedFilters.add(filter);
      }
      _loadComplaintMarkers();
    });
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
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: GoogleMap(
                initialCameraPosition:
                    const CameraPosition(target: universityLocation, zoom: 15),
                markers: _markers,
                onMapCreated: (controller) => _controller.complete(controller),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: complaintTypes.map((filter) {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: const BorderSide(
                                color: Colors.green, width: 1.5),
                          ),
                          backgroundColor: selectedFilters.contains(filter)
                              ? Colors.green.withOpacity(0.2)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 24),
                        ),
                        onPressed: () => _toggleFilter(filter),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: selectedFilters.contains(filter)
                                ? Colors.deepPurple
                                : Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
