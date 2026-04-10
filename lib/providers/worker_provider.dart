import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/worker_model.dart';

class WorkerProvider with ChangeNotifier {
  List<Worker> _workers = [];
  bool _isLoading = false;
  String? _error;

  List<Worker> get workers => _workers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final String baseUrl = "https://rvm-backend-oaot.onrender.com";
  // final String baseUrl = "http://localhost:5000"; // Test local

  // 1. Récupérer tous les travailleurs (Techniciens et Videurs)
  Future<void> fetchWorkers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // On récupère les deux types de travailleurs
      final techResp = await http.get(Uri.parse('$baseUrl/user/role/technicien'));
      final videurResp = await http.get(Uri.parse('$baseUrl/user/role/videur'));

      print("📡 DEBUG FETCH TECH: Code ${techResp.statusCode}, Body: ${techResp.body}");
      print("📡 DEBUG FETCH VIDEUR: Code ${videurResp.statusCode}, Body: ${videurResp.body}");

      List<Worker> combined = [];

      if (techResp.statusCode == 200) {
        final List<dynamic> data = json.decode(techResp.body);
        for (var item in data) {
          try {
            combined.add(Worker.fromJson(item));
          } catch (e) {
            print("❌ Erreur parsing worker: $e");
          }
        }
      }

      if (videurResp.statusCode == 200) {
        final List<dynamic> data = json.decode(videurResp.body);
        for (var item in data) {
          try {
            combined.add(Worker.fromJson(item));
          } catch (e) {
            print("❌ Erreur parsing videur: $e");
          }
        }
      }

      _workers = combined;
      print("✅ TOTAL WORKERS CHARGÉS: ${_workers.length}");
      
      if (techResp.statusCode == 404 || videurResp.statusCode == 404) {
        _error = "Les routes '/user/role/...' n'existent pas sur le serveur Render. Le backend doit être mis à jour.";
      } else if (techResp.statusCode != 200 && videurResp.statusCode != 200) {
        _error = "Erreur de chargement des données (Code: ${techResp.statusCode})";
      }
    } catch (e) {
      _error = "Erreur réseau: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Ajouter un travailleur (Create User)
  Future<bool> addWorker(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/'), // Route racine pour createUser
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchWorkers(); // Rafraîchir la liste
        return true;
      } else {
        final data = json.decode(response.body);
        _error = data['message'] ?? "Erreur d'ajout: ${response.statusCode}";
        return false;
      }
    } catch (e) {
      _error = "Erreur réseau: $e";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Supprimer un travailleur
  Future<bool> deleteWorker(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/user/$id'),
      );

      if (response.statusCode == 200) {
        _workers.removeWhere((w) => w.id == id);
        return true;
      } else {
        _error = "Erreur de suppression";
        return false;
      }
    } catch (e) {
      _error = "Erreur réseau";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
