import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginModel extends ChangeNotifier {
  // Champs contrôleurs
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool showPassword = false;
  String? errorMessage;

  // URL de ton backend Flask
  final String apiUrl = "http://127.0.0.1:5000/login"; // change si besoin

  void togglePassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      errorMessage = "Veuillez remplir tous les champs.";
      notifyListeners();
      return false;
    }

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      isLoading = false;

      if (response.statusCode == 200) {
        // Connexion réussie
        notifyListeners();
        return true;
      } else if (response.statusCode == 401) {
        // Identifiants incorrects
        errorMessage = "Identifiants incorrects.";
        notifyListeners();
        return false;
      } else {
        errorMessage = "Une erreur est survenue.";
        notifyListeners();
        return false;
      }
    } catch (e) {
      isLoading = false;
      errorMessage = "Erreur de connexion au serveur.";
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
