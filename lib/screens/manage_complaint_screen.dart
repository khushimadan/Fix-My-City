import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fix_my_city/screens/full_screen_image.dart';

class ManageComplaintScreen extends StatefulWidget {
  final Map<String, dynamic> data;
  const ManageComplaintScreen({super.key, required this.data});

  String? get complaintDocId => null;

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
  Map<String, String> workerImages = {}; // Stores workerId -> imageUrl
  Map<String, String> workerFeedback = {}; // Stores workerId -> feedback

  @override
  void initState() {
    super.initState();
    fetchComplaintDocId();
    fetchComplaintData();
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

      await fetchComplaintData(); // Now correctly runs after complaintDocId is set
      await fetchComplaintDetails();
      await fetchWorkers();
    }
  }


  Future<void> fetchComplaintData() async {
    if (complaintDocId == null) return;

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('complaints')
          .doc(complaintDocId) // Ensure correct complaint ID is used
          .get();

      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        setState(() {
          workerImages = Map<String, String>.from(data['workerImages'] ?? {});
          workerFeedback = Map<String, String>.from(data['workerFeedback'] ?? {});
        });

        // Debugging logs to check retrieved data
        print("Worker Images: $workerImages");
        print("Worker Feedback: $workerFeedback");
      }
    } catch (e) {
      print("Error fetching complaint data: $e");
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
                        imagePath: widget.data['imageUrl'],
                        isNetwork: true,
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
                    String? imageUrl = workerImages.containsKey(workerId) ? workerImages[workerId] : null;
                    String? feedbackText = workerFeedback.containsKey(workerId) ? workerFeedback[workerId] : null;

                    return ListTile(
                      title: Text(worker['name'], style: const TextStyle(fontSize: 16)),
                      subtitle: Row(
                        children: [
                          // Image display logic
                          imageUrl != null
                              ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FullScreenImage(
                                    imagePath: imageUrl,
                                    isNetwork: true,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.image, color: Colors.blue),
                                const SizedBox(width: 5),
                                Text(
                                  "View Image",
                                  style: const TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Text("Image not uploaded", style: TextStyle(color: Colors.red[400])),

                          const SizedBox(width: 15),

                          // Feedback display logic
                          feedbackText != null
                              ? GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => FeedbackScreen(
                                    complaintDocId: complaintDocId!,
                                    workerId: workerId,
                                  ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.feedback, color: Colors.green),
                                const SizedBox(width: 5),
                                Text(
                                  "View Feedback",
                                  style: const TextStyle(
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : Text("No feedback", style: TextStyle(color: Colors.grey[600])),
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

class FeedbackScreen extends StatelessWidget {
  final String complaintDocId;
  final String workerId;

  const FeedbackScreen({super.key, required this.complaintDocId, required this.workerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Worker Feedback")),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('complaints').doc(complaintDocId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          var data = snapshot.data!.data() as Map<String, dynamic>;
          String feedback = data['workerFeedback']?[workerId] ?? "No feedback available";

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              feedback,
              style: const TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
