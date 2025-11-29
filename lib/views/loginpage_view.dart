import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPageView extends StatefulWidget {
  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  String role = "user"; // choix initial

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> login() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );

      String uid = userCredential.user!.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      String userRole = userDoc["role"];

      if (userRole == "organizer") {
        Navigator.pushNamed(context, "/organizer_home");
      } else {
        Navigator.pushNamed(context, "/user_home");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur : ${e.toString()}")),
      );
    }
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Widget _roleButton(String title, IconData icon, String value) {
    bool selected = (role == value);

    return Container(
      width: 135,
      child: GestureDetector(
        onTap: () => setState(() => role = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFF4A90E2) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? const Color(0xFF4A90E2) : Colors.grey.shade300,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: Colors.blue.shade100,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                )
            ],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: selected ? Colors.white : Colors.black54,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Icon(Icons.lock_outline, size: 70, color: Color(0xFF4A90E2)),
              const SizedBox(height: 20),
              const Text(
                "Connexion",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _roleButton("Utilisateur", Icons.person_outline, "user"),
                        const SizedBox(width: 25),
                        _roleButton("Organisateur", Icons.admin_panel_settings_outlined, "organizer"),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: _email,
                      decoration: InputDecoration(
                        labelText: "Email",
                        prefixIcon: const Icon(Icons.email, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _password,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: "Mot de passe",
                        prefixIcon: const Icon(Icons.lock, size: 20),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: login,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF4A90E2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text("Se connecter", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        if (role == "user") {
                          Navigator.pushNamed(context, "/register_user");
                        } else {
                          Navigator.pushNamed(context, "/register_organizer");
                        }
                      },
                      child: const Text("Créer un compte"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
