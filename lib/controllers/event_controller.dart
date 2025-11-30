
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';

class EventController {
  final CollectionReference eventsCollection =
      FirebaseFirestore.instance.collection('events');

  Future<void> createEvent(EventModel event) async {
    await eventsCollection.add(event.toMap());
  }

  Stream<List<EventModel>> getEvents() {
    return eventsCollection
        .orderBy('datetime', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => EventModel.fromMap(doc)).toList());
  }
}
