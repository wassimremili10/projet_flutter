import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  String? id;
  String title;
  String category;
  String description;
  DateTime dateTime;
  String location;
  double? latitude;
  double? longitude;
  int capacity;
  double price;

  EventModel({
    this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.dateTime,
    required this.location,
    this.latitude,
    this.longitude,
    required this.capacity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'category': category,
      'description': description,
      'datetime': dateTime,
      'location': location,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'price': price,
      'created_at': Timestamp.now(),
    };
  }

  factory EventModel.fromMap(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'],
      category: data['category'],
      description: data['description'],
      dateTime: (data['datetime'] as Timestamp).toDate(),
      location: data['location'],
      latitude: data['latitude'],
      longitude: data['longitude'],
      capacity: data['capacity'],
      price: (data['price'] as num).toDouble(),
    );
  }
}
