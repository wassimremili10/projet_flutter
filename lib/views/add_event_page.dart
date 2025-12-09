import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'map_picker_page.dart';
import 'organizer_events_page.dart';

class AddEventPage extends StatefulWidget {
  const AddEventPage({super.key});

  @override
  State<AddEventPage> createState() => _AddEventPageState();
}

class _AddEventPageState extends State<AddEventPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String? selectedLocation;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  Future<void> _addEvent() async {
    if (_formKey.currentState!.validate()) {
      if (selectedLocation == null || selectedDate == null || selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez remplir tous les champs")),
        );
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DateTime eventDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection("events").add({
        "title": _titleController.text,
        "description": _descriptionController.text,
        "category": _categoryController.text,
        "datetime": Timestamp.fromDate(eventDateTime),
        "location": selectedLocation,
        "capacity": int.tryParse(_capacityController.text) ?? 0,
        "price": double.tryParse(_priceController.text) ?? 0.0,
        "created_at": Timestamp.now(),
        "organizer_id": user.uid, // ✅ Stocke l'organisateur
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OrganizerEventsPage()),
      );
    }
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      {bool readOnly = false, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? "Champ requis" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onTap: () async {
        if (!readOnly) return;

        if (label.contains("Date")) {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: selectedDate ?? DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = pickedDate;
              _dateController.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            });
          }
        } else if (label.contains("Heure")) {
          TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: selectedTime ?? TimeOfDay.now(),
          );
          if (pickedTime != null) {
            setState(() {
              selectedTime = pickedTime;
              _timeController.text =
                  "${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}";
            });
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Ajouter un événement"), backgroundColor: Colors.blue),
      backgroundColor: Colors.grey.shade200,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, "Titre", Icons.title),
              const SizedBox(height: 12),
              _buildTextField(_descriptionController, "Description", Icons.description),
              const SizedBox(height: 12),
              // Catégorie
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    labelText: "Catégorie",
                    prefixIcon: Icon(Icons.category),
                  ),
                  value: _categoryController.text.isEmpty ? null : _categoryController.text,
                  items: const [
                    DropdownMenuItem(value: "Cinéma", child: Text("Cinéma")),
                    DropdownMenuItem(value: "Sport", child: Text("Sport")),
                    DropdownMenuItem(value: "Art", child: Text("Art")),
                    DropdownMenuItem(value: "Music", child: Text("Music")),
                  ],
                  onChanged: (value) => _categoryController.text = value!,
                  validator: (value) => value == null ? "Veuillez choisir une catégorie" : null,
                ),
              ),
              const SizedBox(height: 12),
              _buildTextField(_dateController, "Date", Icons.calendar_today, readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(_timeController, "Heure", Icons.access_time, readOnly: true),
              const SizedBox(height: 12),
              _buildTextField(_capacityController, "Nombre de places", Icons.people, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              _buildTextField(_priceController, "Prix", Icons.monetization_on, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapPickerPage()),
                  );
                  if (result != null) setState(() => selectedLocation = result);
                },
                icon: const Icon(Icons.map),
                label: Text(selectedLocation == null ? "Choisir le lieu" : "Lieu choisi : $selectedLocation"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _addEvent,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text("Ajouter", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
