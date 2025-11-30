import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerPage extends StatefulWidget {
  const MapPickerPage({super.key});

  @override
  State<MapPickerPage> createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng selected = LatLng(36.8065, 10.1815); // Tunis par défaut
  String? address; // Adresse sélectionnée

  // Fonction pour récupérer le nom de l'adresse via OpenStreetMap
  Future<void> fetchAddress(LatLng point) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${point.latitude}&lon=${point.longitude}'
    );

    final response = await http.get(url, headers: {'User-Agent': 'FlutterApp'});

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        address = data['display_name'] ?? "Adresse inconnue";
      });
    } else {
      setState(() {
        address = "Adresse inconnue";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choisir un lieu"),
        backgroundColor: Colors.blue.shade700,
      ),
      body: FlutterMap(
        options: MapOptions(
           initialCenter: selected,
          initialZoom: 13,

          onTap: (tapPosition, point) {
            setState(() => selected = point);
            fetchAddress(point); // Récupère le nom de l'adresse
          },
        ),
        children: [
          TileLayer(
            urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: "com.example.app",
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: selected,
                width: 40,
                height: 40,
                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (address != null) {
            Navigator.pop(context, address); // Retourne le nom de l'adresse
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Veuillez sélectionner un lieu")),
            );
          }
        },
        backgroundColor: Colors.blue.shade700,
        icon: const Icon(Icons.check),
        label: Text(address ?? "Valider ce lieu"),
      ),
    );
  }
}
