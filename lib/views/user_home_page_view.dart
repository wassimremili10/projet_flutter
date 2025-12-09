import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UserHomePageView extends StatefulWidget {
  const UserHomePageView({super.key});

  @override
  State<UserHomePageView> createState() => _UserHomePageViewState();
}

class _UserHomePageViewState extends State<UserHomePageView> {
  String? filterCategory;
  DateTime? filterDate;
  String? filterLocation;
  double? filterMaxPrice;

  // -------------------------------------------------------------
  // Filtres
  // -------------------------------------------------------------
  void _openFilters() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const Text("Filtres",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Catégorie"),
                  value: filterCategory,
                  items: const [
                    DropdownMenuItem(value: "Music", child: Text("Musique")),
                    DropdownMenuItem(value: "Sport", child: Text("Sport")),
                    DropdownMenuItem(value: "Art", child: Text("Art")),
                    DropdownMenuItem(value: "Cinéma", child: Text("Cinéma")),
                  ],
                  onChanged: (val) => setState(() => filterCategory = val),
                ),

                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => filterDate = picked);
                    }
                  },
                  child: Text(filterDate == null
                      ? "Filtrer par date"
                      : "${filterDate!.day}/${filterDate!.month}/${filterDate!.year}"),
                ),

                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(labelText: "Lieu"),
                  onChanged: (v) => setState(() => filterLocation = v.trim()),
                ),

                const SizedBox(height: 12),
                TextField(
                  decoration: const InputDecoration(
                      labelText: "Prix max", prefixIcon: Icon(Icons.money)),
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      setState(() => filterMaxPrice = double.tryParse(v)),
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            filterCategory = null;
                            filterDate = null;
                            filterLocation = null;
                            filterMaxPrice = null;
                          });
                          Navigator.pop(context);
                        },
                        style:
                            ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text("Réinitialiser"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: const Text("Appliquer"),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // -------------------------------------------------------------
  // Enregistrement d'un avis + note
  // -------------------------------------------------------------
  Future<void> _addReview(String eventId) async {
    final user = FirebaseAuth.instance.currentUser!;
    double rating = 3;
    final TextEditingController commentController = TextEditingController();

    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Donner un avis"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar.builder(
                  initialRating: 3,
                  minRating: 1,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemSize: 30,
                  itemBuilder: (c, _) => const Icon(Icons.star, color: Colors.orange),
                  onRatingUpdate: (v) => rating = v,
                ),
                TextField(
                  controller: commentController,
                  decoration:
                      const InputDecoration(labelText: "Commentaire..."),
                ),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler")),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection("events")
                      .doc(eventId)
                      .collection("reviews")
                      .add({
                    "user_id": user.uid,
                    "rating": rating,
                    "comment": commentController.text,
                    "date": Timestamp.now(),
                  });

                  Navigator.pop(context);
                },
                child: const Text("Publier"),
              )
            ],
          );
        });
  }

  // -------------------------------------------------------------
  // Widget Avis + formulaire après date
  // -------------------------------------------------------------
  Widget _reviewsSection(String eventId, DateTime eventDate) {
    final bool canReview = eventDate.isBefore(DateTime.now());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Avis utilisateurs",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

        const SizedBox(height: 6),

        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection("events")
              .doc(eventId)
              .collection("reviews")
              .orderBy("date", descending: true)
              .snapshots(),
          builder: (context, snap) {
            if (!snap.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final reviews = snap.data!.docs;

            if (reviews.isEmpty) {
              return const Text("Aucun avis pour le moment.");
            }

            return Column(
              children: reviews.map((doc) {
                final data = doc.data() as Map<String, dynamic>;

                return ListTile(
                  leading: Icon(Icons.person, color: Colors.blue.shade700),
                  title: Row(
                    children: [
                      Text("${data['rating']}★"),
                    ],
                  ),
                  subtitle: Text(data["comment"] ?? ""),
                );
              }).toList(),
            );
          },
        ),

        const SizedBox(height: 10),

        if (canReview)
          ElevatedButton(
            onPressed: () => _addReview(eventId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Ajouter un avis"),
          )
        else
          const Text(
            "Vous pouvez noter cet événement après sa date.",
            style: TextStyle(color: Colors.grey),
          )
      ],
    );
  }

  // -------------------------------------------------------------
  // BUILD
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F1FA),
      appBar: AppBar(
        title: const Text("Événements disponibles"),
        backgroundColor: const Color(0xFF3B7DDD),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _openFilters,
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("events")
            .orderBy("datetime", descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          List docs = snapshot.data!.docs;

          // ---------------- FILTRAGE LOCAL -----------------
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data["datetime"] as Timestamp).toDate();
            final price = (data["price"] ?? 0).toDouble();

            bool okCat = filterCategory == null || data["category"] == filterCategory;
            bool okDate = filterDate == null ||
                (date.year == filterDate!.year &&
                    date.month == filterDate!.month &&
                    date.day == filterDate!.day);
            bool okLoc = filterLocation == null ||
                filterLocation!.isEmpty ||
                (data["location"] ?? "")
                    .toLowerCase()
                    .contains(filterLocation!.toLowerCase());
            bool okPrice = filterMaxPrice == null || price <= filterMaxPrice!;

            return okCat && okDate && okLoc && okPrice;
          }).toList();

          if (docs.isEmpty) {
            return const Center(child: Text("Aucun événement trouvé."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final event = docs[index];
              final data = event.data() as Map<String, dynamic>;
              final eventId = event.id;

              final date = (data["datetime"] as Timestamp).toDate();

              return Card(
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 6,
                margin: const EdgeInsets.symmetric(vertical: 10),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data["title"],
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue)),
                      const SizedBox(height: 10),
                      Text(data["description"]),

                      const SizedBox(height: 10),

                      Text("Lieu : ${data["location"]}"),
                      Text(
                          "Date : ${date.day}/${date.month}/${date.year} à ${date.hour}:${date.minute.toString().padLeft(2, '0')}"),
                      Text("Prix : ${data["price"]} DT"),
                      Text("Places restantes : ${data["capacity"]}"),

                      const SizedBox(height: 20),
                       const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(data["category"] ?? "Catégorie")),
                        ],
                      ),


                      // Avis + notation
                      _reviewsSection(eventId, date),
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