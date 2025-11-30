import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../controllers/event_controller.dart';
import '../models/event_model.dart';

class UserHomePageView extends StatelessWidget {
  final EventController _controller = EventController();

  // Fonction d'inscription
  Future<void> _registerToEvent(String eventId, BuildContext context) async {
    try {
      await FirebaseFirestore.instance
          .collection("events")
          .doc(eventId)
          .collection("registrations")
          .add({
        "registered_at": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inscription réussie !")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FA), // fond bleu clair
      appBar: AppBar(
        title: const Text("Événements disponibles"),
        backgroundColor: const Color(0xFF3B7DDD), // bleu principal
      ),
      body: StreamBuilder<List<EventModel>>(
        stream: _controller.getAllEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text("Aucun événement disponible."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 6,
                shadowColor: Colors.blue.shade100,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B7DDD),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Catégorie
                      Row(
                        children: [
                          const Icon(Icons.category, size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            event.category,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Date & heure
                      Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(
                            "${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} • "
                            "${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Lieu
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 20, color: Colors.grey),
                          const SizedBox(width: 6),
                          Text(event.location,
                              style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Description
                      Text(
                        event.description,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 12),

                      // Badges Capacité & Prix
                      Row(
                        children: [
                          Chip(
                            label: Text(
                              "Places : ${event.capacity}",
                              style: const TextStyle(color: Color(0xFF3B7DDD)),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                          const SizedBox(width: 10),
                          Chip(
                            label: Text(
                              "Prix : ${event.price} DT",
                              style: const TextStyle(color: Color(0xFF3B7DDD)),
                            ),
                            backgroundColor: Colors.blue.shade50,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Bouton S'inscrire
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3B7DDD),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: () => _registerToEvent(event.id!, context),
                          child: const Text(
                            "S'inscrire",
                            style: TextStyle(fontSize: 17, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
