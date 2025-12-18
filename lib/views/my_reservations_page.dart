import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyReservationsPage extends StatelessWidget {
  const MyReservationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mes réservations"),
        backgroundColor: Colors.blue,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("events").snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!.docs;

          return ListView(
            children: events.map((eventDoc) {
              final eventData =
                  eventDoc.data() as Map<String, dynamic>;
              final eventId = eventDoc.id;

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("events")
                    .doc(eventId)
                    .collection("reservations")
                    .where("user_id", isEqualTo: userId)
                    .snapshots(),
                builder: (context, resSnap) {
                  if (!resSnap.hasData || resSnap.data!.docs.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  return Column(
                    children: resSnap.data!.docs.map((resDoc) {
                      final res =
                          resDoc.data() as Map<String, dynamic>;

                      return Card(
                        margin: const EdgeInsets.all(10),
                        child: ListTile(
                          leading: const Icon(Icons.event_available),
                          title: Text(eventData["title"]),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Places : ${res["seats"]}"),
                              Text("Total : ${res["total_price"]} DT"),
                              Text(
                                "Date : ${(res["timestamp"] as Timestamp).toDate().day}/"
                                "${(res["timestamp"] as Timestamp).toDate().month}/"
                                "${(res["timestamp"] as Timestamp).toDate().year}",
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
