import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventController {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  // Créer un événement
  Future<void> createEvent(EventModel event) async {
    await eventsCollection.add(event.toMap());
  }

  // Récupérer tous les événements (pour les utilisateurs)
  Stream<List<EventModel>> getAllEvents() {
    return eventsCollection
        .orderBy('datetime', descending: false) // Tri par date
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromMap(doc)).toList());
  }

  // Récupérer seulement les événements d'un organisateur (optionnel)
  Stream<List<EventModel>> getEventsByOrganizer(String organizerId) {
    return eventsCollection
        .where('organizerId', isEqualTo: organizerId)
        .orderBy('datetime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromMap(doc)).toList());
  }
}
