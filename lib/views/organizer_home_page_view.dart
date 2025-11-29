import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/event_model.dart';
import '../controllers/event_controller.dart';

class OrganizerHomePageView extends StatefulWidget {
  @override
  State<OrganizerHomePageView> createState() => _OrganizerHomePageViewState();
}

class _OrganizerHomePageViewState extends State<OrganizerHomePageView> {
  final _formKey = GlobalKey<FormState>();
  final _controller = EventController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  double? _latitude;
  double? _longitude;

  Future<void> _pickDate() async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    TimeOfDay? time =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _locationController.text = '$_latitude, $_longitude';
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedDate == null || _selectedTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Veuillez sélectionner date et heure")),
        );
        return;
      }

      EventModel event = EventModel(
        title: _titleController.text.trim(),
        category: _categoryController.text.trim(),
        description: _descriptionController.text.trim(),
        dateTime: DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
        location: _locationController.text.trim(),
        latitude: _latitude,
        longitude: _longitude,
        capacity: int.parse(_capacityController.text.trim()),
        price: _priceController.text.isEmpty
            ? 0
            : double.parse(_priceController.text.trim()),
      );

      await _controller.createEvent(event);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Événement créé avec succès !")),
      );

      _formKey.currentState!.reset();
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _latitude = null;
        _longitude = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Créer un événement"),
        backgroundColor: const Color(0xFF4A90E2),
      ),
      backgroundColor: const Color(0xFFF2F2F7),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildTextField(_titleController, "Titre", Icons.title),
                  const SizedBox(height: 15),
                  _buildTextField(_categoryController, "Catégorie", Icons.category),
                  const SizedBox(height: 15),
                  _buildTextField(_descriptionController, "Description", Icons.description, maxLines: 3),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.calendar_today),
                          label: Text(_selectedDate == null
                              ? "Choisir date"
                              : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}"),
                          onPressed: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          label: Text(_selectedTime == null
                              ? "Choisir heure"
                              : "${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2,'0')}"),
                          onPressed: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(_locationController, "Lieu (géolocalisation)", Icons.location_on, enabled: false),
                  TextButton.icon(
                    icon: const Icon(Icons.my_location),
                    label: const Text("Obtenir ma position"),
                    onPressed: _getCurrentLocation,
                  ),
                  const SizedBox(height: 15),
                  _buildTextField(_capacityController, "Nombre de places", Icons.people, keyboardType: TextInputType.number),
                  const SizedBox(height: 15),
                  _buildTextField(_priceController, "Prix d’entrée (optionnel)", Icons.attach_money, keyboardType: TextInputType.number),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A90E2),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: _submitForm,
                      child: const Text("Créer l'événement", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            // Affichage des événements
            StreamBuilder<List<EventModel>>(
              stream: _controller.getAllEvents(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final events = snapshot.data!;
                if (events.isEmpty) return const Text("Aucun événement créé.");
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(event.title),
                        subtitle: Text(
                            "${event.category} • ${event.dateTime.day}/${event.dateTime.month}/${event.dateTime.year} ${event.dateTime.hour}:${event.dateTime.minute.toString().padLeft(2,'0')}"),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    int maxLines = 1,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) return 'Veuillez remplir ce champ';
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }
}
