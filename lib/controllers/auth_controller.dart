import '../models/auth_model.dart';

class AuthController {
  final List<AuthModel> _users = [];

  // REGISTER
  String? register(String nom, String prenom, String email, String password) {
    if (_users.any((u) => u.email == email)) {
      return "Email déjà utilisé";
    }

    _users.add(
      AuthModel(
        id: DateTime.now().toString(),
        nom: nom,
        prenom: prenom,
        email: email,
        password: password,
      ),
    );

    return null; // succès
  }

  // LOGIN
  bool login(String email, String password) {
    return _users.any((u) => u.email == email && u.password == password);
  }
}
