import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ManageComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ManageComplaintScreen({super.key, required this.data});

  @override
  State<ManageComplaintScreen> createState() => _ManageComplaintScreenState();
}

class _ManageComplaintScreenState extends State<ManageComplaintScreen> {
  List<DocumentSnapshot> workers = [];
  List<DocumentSnapshot> selectedWorkers = [];
  bool workersAssigned = false;
  bool complaintClosed = false;
  String? complaintDocId;
  List<String> workerImageUrls = [];

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
      await fetchWorkers();
    }
  }

  Future<void> fetchWorkers() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('workers')
          .where('category', isEqualTo: widget.data['category'].toString().trim())
          .get();

      setState(() {
        workers = snapshot.docs;
      });
    } catch (e) {
      debugPrint("Error fetching workers: $e");
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
      List assignedWorkerIds = data['assignedWorkers'] ?? [];

      if (assignedWorkerIds.isNotEmpty) {
        var workerSnapshots = await FirebaseFirestore.instance
            .collection('workers')
            .where('workerId', whereIn: assignedWorkerIds)
            .get();

        setState(() {
          selectedWorkers = workerSnapshots.docs;
          workersAssigned = true;
        });
      }

      setState(() {
        complaintClosed = data['status'] == 'Completed';
        // Fetching the worker images associated with this complaint
        workerImageUrls = List<String>.from(data['workerImageUrls'] ?? []);
      });
    }
  }

  Future<void> assignWorkers() async {
    if (complaintDocId == null || selectedWorkers.isEmpty) return;

    List<String> selectedWorkerIds = selectedWorkers.map((worker) => worker['workerId'] as String).toList();

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId)
        .update({
      'status': 'In Progress',
      'assignedWorkers': FieldValue.arrayUnion(selectedWorkerIds),
    });

    for (String workerId in selectedWorkerIds) {
      var workerQuery = await FirebaseFirestore.instance
          .collection('workers')
          .where('workerId', isEqualTo: workerId)
          .get();

      if (workerQuery.docs.isNotEmpty) {
        String workerDocId = workerQuery.docs.first.id;
        var workerData = workerQuery.docs.first.data();

        List<dynamic> assignedComplaintNos = List.from(workerData['assignedComplaintNo'] ?? []);

        if (!assignedComplaintNos.contains(widget.data['complaintNo'])) {
          assignedComplaintNos.add(widget.data['complaintNo']);
        }

        await FirebaseFirestore.instance
            .collection('workers')
            .doc(workerDocId)
            .update({
          'assignedComplaintNo': assignedComplaintNos,
        });
      }
    }
  }

  Future<void> closeComplaint() async {
    if (complaintDocId == null) return;

    await FirebaseFirestore.instance
        .collection('complaints')
        .doc(complaintDocId)
        .update({'status': 'Completed'});

    setState(() {
      complaintClosed = true;
    });

    fetchComplaintDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: const Color(0xFF009944),
        title: const Text(
          "Manage Complaint",
          style: TextStyle(fontFamily: 'Poppins', fontSize: 24),
        ),
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
            const SizedBox(height: 20),
            if (complaintClosed) ...[
              const Center(
                child: Text(
                  "Complaint Closed",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ),
            ] else ...[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: () async {
                  List<DocumentSnapshot>? result = await showDialog(
                    context: context,
                    builder: (context) => WorkerSelectionDialog(
                      workers: workers,
                      selectedWorkers: selectedWorkers,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      selectedWorkers = result;
                      workersAssigned = true;
                    });
                    await assignWorkers();
                  }
                },
                child: Text(workersAssigned ? "Assign More Workers" : "Assign Workers"),
              ),
              const SizedBox(height: 20),
              if (workersAssigned && selectedWorkers.isNotEmpty) ...[
                const Text(
                  "Assigned Workers:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedWorkers.map((worker) {
                    String workerId = worker['workerId'];
                    String imageUrl = workerImageUrls.isNotEmpty && workerImageUrls.length > selectedWorkers.indexOf(worker)
                        ? workerImageUrls[selectedWorkers.indexOf(worker)]
                        : ''; // If image URL exists, show it.
                    return ListTile(
                      title: Text(worker['name'], style: const TextStyle(fontSize: 16)),
                      subtitle: Row(
                        children: [
                          Text(imageUrl.isNotEmpty ? "View Image" : "Image not uploaded",
                              style: TextStyle(
                                color: imageUrl.isNotEmpty ? Colors.blue : Colors.red[400],
                                decoration: imageUrl.isNotEmpty ? TextDecoration.underline : null,
                              )),
                          const SizedBox(width: 10),
                          if (imageUrl.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.image, color: Colors.blue),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Worker Image"),
                                    content: Image.network(imageUrl),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Close"),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                        ],
                      ),

                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
              ],
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: const TextStyle(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                onPressed: closeComplaint,
                child: const Text("Close Complaint"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Worker Selection Dialog with Pre-Selected Workers
class WorkerSelectionDialog extends StatefulWidget {
  final List<DocumentSnapshot> workers;
  final List<DocumentSnapshot> selectedWorkers;

  const WorkerSelectionDialog({super.key, required this.workers, required this.selectedWorkers});

  @override
  WorkerSelectionDialogState createState() => WorkerSelectionDialogState();
}

class WorkerSelectionDialogState extends State<WorkerSelectionDialog> {
  late List<DocumentSnapshot> selectedWorkers;

  @override
  void initState() {
    super.initState();
    selectedWorkers = List.from(widget.selectedWorkers);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Select Workers"),
      content: SingleChildScrollView(
        child: Column(
          children: widget.workers.map((worker) {
            bool isSelected = selectedWorkers.any((w) => w.id == worker.id);
            return CheckboxListTile(
              title: Text(worker['name']),
              value: isSelected,
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedWorkers.add(worker);
                  } else {
                    selectedWorkers.removeWhere((w) => w.id == worker.id);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, selectedWorkers),
          child: const Text("Assign"),
        ),
      ],
    );
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
