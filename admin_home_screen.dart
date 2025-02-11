import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = {};
  bool filterByArea = true;

  final List<String> areas = ['Academic Block 1', "Academic Block 2", "Academic Block 3", "Other Areas"];
  final List<String> complaintTypes = ["Garbage", "Street Light", "Stray Dogs", "Water Logging"];

  static const LatLng universityLocation = LatLng(26.8437, 75.5657);

  @override
  void initState() {
    super.initState();
    _loadComplaintMarkers();
  }

  void _loadComplaintMarkers() async {
    try {
      QuerySnapshot complaints = await FirebaseFirestore.instance.collection('complaints').get();

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

  Future<void> _moveCameraToMarkers(Set<Marker> markers) async {
    final GoogleMapController controller = await _controller.future;

    if (markers.isNotEmpty) {
      LatLngBounds bounds = _getBoundsFromMarkers(markers);
      CameraUpdate cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 80);

      await controller.animateCamera(cameraUpdate);

      double currentZoom = await controller.getZoomLevel();
      if (currentZoom > 14) {
        await controller.animateCamera(CameraUpdate.zoomTo(12));
      }
    } else {
      controller.animateCamera(CameraUpdate.newCameraPosition(
        const CameraPosition(target: universityLocation, zoom: 10),
      ));
    }
  }

  LatLngBounds _getBoundsFromMarkers(Set<Marker> markers) {
    double minLat = markers.first.position.latitude;
    double minLng = markers.first.position.longitude;
    double maxLat = markers.first.position.latitude;
    double maxLng = markers.first.position.longitude;

    for (var marker in markers) {
      if (marker.position.latitude < minLat) minLat = marker.position.latitude;
      if (marker.position.latitude > maxLat) maxLat = marker.position.latitude;
      if (marker.position.longitude < minLng) minLng = marker.position.longitude;
      if (marker.position.longitude > maxLng) maxLng = marker.position.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(minLat, minLng),
      northeast: LatLng(maxLat, maxLng),
    );
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
                ? FadeInImage.assetNetwork(
              placeholder: 'images/logo.png',
              image: data['imageUrl'],
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.image_not_supported, size: 50, color: Colors.grey);
              },
            )
                : const Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
            const SizedBox(height: 10),
            Text(data['description'] ?? "No description available"),
            Text("Status: ${data['status'] ?? 'Pending'}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close")),
        ],
      ),
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
          title: const Text("Admin Home", style: TextStyle(fontFamily: 'Poppins', fontSize: 24)),
        ),
        body: Column(
          children: [
            Expanded(
              flex: 6,
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(target: universityLocation, zoom: 7),
                markers: _markers,
                onMapCreated: (controller) => _controller.complete(controller),
              ),
            ),
            const SizedBox(height: 10),
            //
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  ToggleButtons(
                    borderColor: Colors.green,
                    selectedBorderColor: Colors.green,
                    fillColor: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    isSelected: [filterByArea, !filterByArea],
                    onPressed: (index) {
                      setState(() {
                        filterByArea = index == 0;
                      });
                    },
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Filter by Area")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Filter by Type")),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (filterByArea ? areas : complaintTypes).map((filter) {
                      return GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            border: Border.all(color: const Color(0xFF009944), width: 2),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.white,
                          ),
                          child: Text(filter, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
