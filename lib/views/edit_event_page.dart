import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'map_picker_page.dart';

class EditEventPage extends StatefulWidget {
  final String eventId;
  const EditEventPage({super.key, required this.eventId});

  @override
  State<EditEventPage> createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedLocation;

  @override
  void initState() {
    super.initState();
    _loadEvent();
  }

  // ------------------- LOAD EVENT DATA -------------------
  Future<void> _loadEvent() async {
    final doc = await FirebaseFirestore.instance
        .collection("events")
        .doc(widget.eventId)
        .get();

    if (!doc.exists) return;

    final data = doc.data()!;

    _titleController.text = data["title"] ?? "";
    _descriptionController.text = data["description"] ?? "";
    _categoryController.text = data["category"] ?? "";
    _priceController.text = data["price"] != null ? data["price"].toString() : "";
    _capacityController.text = data["capacity"] != null ? data["capacity"].toString() : "";
    selectedLocation = data["location"] ?? "";

    if (data["datetime"] != null) {
      final dt = (data["datetime"] as Timestamp).toDate();
      selectedDate = dt;
      selectedTime = TimeOfDay(hour: dt.hour, minute: dt.minute);
    }

    setState(() {});
  }

  // ------------------- UPDATE EVENT DATA -------------------
  Future<void> _updateEvent() async {
    if (!_formKey.currentState!.validate()) return;

    DateTime eventDateTime = DateTime(
      selectedDate?.year ?? DateTime.now().year,
      selectedDate?.month ?? DateTime.now().month,
      selectedDate?.day ?? DateTime.now().day,
      selectedTime?.hour ?? 12,
      selectedTime?.minute ?? 0,
    );

    await FirebaseFirestore.instance
        .collection("events")
        .doc(widget.eventId)
        .update({
      "title": _titleController.text,
      "description": _descriptionController.text,
      "category": _categoryController.text,
      "price": double.tryParse(_priceController.text) ?? 0,
      "capacity": int.tryParse(_capacityController.text) ?? 0,
      "location": selectedLocation,
      "datetime": Timestamp.fromDate(eventDateTime),
      // ❌ PAS DE organizer_id ICI
    });

    Navigator.pop(context);
  }

  // ------------------- UI -------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modifier l'événement"),
        backgroundColor: Colors.blue,
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Titre"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
                validator: (v) => v!.isEmpty ? "Champ requis" : null,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: "Catégorie"),
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: "Prix"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Capacité"),
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  selectedDate == null
                      ? "Sélectionner la date"
                      : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  selectedTime == null
                      ? "Sélectionner l'heure"
                      : "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MapPickerPage()),
                  );
                  if (result != null) {
                    setState(() => selectedLocation = result);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: Text(
                  selectedLocation == null
                      ? "Choisir le lieu"
                      : "Lieu : $selectedLocation",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _updateEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child: const Text(
                  "Enregistrer",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
