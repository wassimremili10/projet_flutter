
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  // 🔽 Ouvre le panel de filtres
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
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Filtres",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),

                // Catégorie
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: "Catégorie"),
                  value: filterCategory,
                  items: const [
                    DropdownMenuItem(value: "Music", child: Text("Musique")),
                    DropdownMenuItem(value: "Sport", child: Text("Sport")),
                    DropdownMenuItem(value: "Art", child: Text("Art")),
                    DropdownMenuItem(value: "Cinéma", child: Text("Cinéma")),
                  ],
                  onChanged: (value) => setState(() => filterCategory = value),
                ),
                const SizedBox(height: 10),

                // Date
                ElevatedButton(
                  onPressed: () async {
                    DateTime? d = await showDatePicker(
                      context: context,
                      initialDate: filterDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setState(() => filterDate = d);
                  },
                  child: Text(filterDate == null
                      ? "Filtrer par date"
                      : "Date : ${filterDate!.day}/${filterDate!.month}/${filterDate!.year}"),
                ),
                const SizedBox(height: 10),

                // Lieu
                TextField(
                  decoration: const InputDecoration(labelText: "Lieu"),
                  onChanged: (value) =>
                      setState(() => filterLocation = value.trim()),
                ),
                const SizedBox(height: 10),

                // Prix maximum
                TextField(
                  decoration: const InputDecoration(
                      labelText: "Prix maximum (DT)",
                      prefixIcon: Icon(Icons.monetization_on)),
                  keyboardType: TextInputType.number,
                  onChanged: (val) {
                    setState(() {
                      filterMaxPrice = double.tryParse(val);
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Boutons
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
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red),
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
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // 🔽 Réserver plusieurs places avec paiement simulé
  Future<void> _reserveEvent(
      String eventId, int availableCapacity, double price) async {
    int selectedSeats = 1;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Réserver un événement"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Nombre de places disponibles: $availableCapacity"),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                        onPressed: selectedSeats > 1
                            ? () => setStateDialog(() => selectedSeats--)
                            : null,
                        icon: const Icon(Icons.remove)),
                    Text("$selectedSeats"),
                    IconButton(
                        onPressed: selectedSeats < availableCapacity
                            ? () => setStateDialog(() => selectedSeats++)
                            : null,
                        icon: const Icon(Icons.add)),
                  ],
                ),
                const SizedBox(height: 10),
                Text("Prix total: ${selectedSeats * price} DT"),
              ],
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler")),
              ElevatedButton(
                  onPressed: () async {
                    // 🔹 Simuler paiement
                    bool paymentSuccess = true; // ici tu peux intégrer Stripe test
                    if (paymentSuccess) {
                      // 🔹 Enregistrer la réservation
                      await FirebaseFirestore.instance
                          .collection("events")
                          .doc(eventId)
                          .collection("registrations")
                          .add({
                        "seats": selectedSeats,
                        "paid": true,
                        "registered_at": Timestamp.now(),
                      });

                      // 🔹 Mettre à jour la capacité restante
                      await FirebaseFirestore.instance
                          .collection("events")
                          .doc(eventId)
                          .update({
                        "capacity": availableCapacity - selectedSeats
                      });

                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                "Réservation réussie pour $selectedSeats place(s)!")),
                      );
                    }
                  },
                  child: const Text("Confirmer")),
            ],
          );
        });
      },
    );
  }

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
          ),
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

          // 🔥 FILTRAGE LOCAL
          docs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final date = (data["datetime"] as Timestamp).toDate();
            final double price = (data["price"] ?? 0).toDouble();

            bool matchCat =
                filterCategory == null || data["category"] == filterCategory;

            bool matchDate = filterDate == null ||
                (date.year == filterDate!.year &&
                    date.month == filterDate!.month &&
                    date.day == filterDate!.day);

            bool matchLoc =
                filterLocation == null ||
                    filterLocation!.isEmpty ||
                    (data["location"] ?? "")
                        .toString()
                        .toLowerCase()
                        .contains(filterLocation!.toLowerCase());

            bool matchPrice = filterMaxPrice == null || price <= filterMaxPrice!;

            return matchCat && matchDate && matchLoc && matchPrice;
          }).toList();

          if (docs.isEmpty) {
            return const Center(
                child: Text("Aucun événement ne correspond aux filtres."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              final eventId = docs[index].id;
              final date = (data["datetime"] as Timestamp).toDate();
              final capacity = (data["capacity"] ?? 0) as int;
              final price = (data["price"] ?? 0).toDouble();

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
                      Text(
                        data["title"] ?? "Titre",
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.category, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(data["category"] ?? "Catégorie")),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 20),
                          const SizedBox(width: 6),
                          Text("${date.day}/${date.month}/${date.year} • ${date.hour}:${date.minute.toString().padLeft(2, '0')}"),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 20),
                          const SizedBox(width: 6),
                          Expanded(child: Text(data["location"] ?? "Lieu")),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(data["description"] ?? "Aucune description"),
                      const SizedBox(height: 10),
                      Text("Prix : $price DT",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Text("Places disponibles : $capacity",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: capacity > 0
                              ? () => _reserveEvent(eventId, capacity, price)
                              : null,
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                          child: const Text("Reserver",
                              style: TextStyle(color: Colors.white)),
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
