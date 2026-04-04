import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MachineProvider with ChangeNotifier {
  List<Map<String, dynamic>> _machines = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get machines => _machines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Remplacez cette URL par votre véritable URL de backend
  final String baseUrl = "https://rvm-backend-oaot.onrender.com";

  // Initialiser avec des données locales pour simuler
  void setInitialMachines(List<Map<String, dynamic>> initialMachines) {
    if (_machines.isEmpty) {
      _machines = List.from(initialMachines);
      notifyListeners();
    }
  }

  // --- METHODES POUR API (Backend) ---

  // 1. Récupérer toutes les machines
  Future<void> fetchMachines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // DÉCOMMENTER POUR UTILISER L'API:

      final response = await http.get(Uri.parse('$baseUrl/machine/search'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _machines = data.map((json) => json as Map<String, dynamic>).toList();
      } else {
        _error = "Erreur de chargement: ${response.statusCode}";
      }

      // Simulation asynchrone
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Ajouter une machine
  Future<bool> addMachine(Map<String, dynamic> newMachine) async {
    _isLoading = true;
    notifyListeners();

    bool success = false;

    try {
      // DÉCOMMENTER POUR UTILISER L'API:

      final response = await http.post(
        Uri.parse('$baseUrl/machine/create'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newMachine),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        final addedMachine = json.decode(response.body);
        _machines.add(addedMachine);
        success = true;
      } else {
        // En cas d'erreur API, on simule l'ajout pour le démo si besoin
        // Mais attention, on ne veut pas l'ajouter deux fois.
        _error = "Erreur d'ajout (Code: ${response.statusCode}). Simulation activée.";
        _machines.add(newMachine);
        success = true; 
      }

      // Simulation asynchrone pour l'UI
      await Future.delayed(const Duration(seconds: 1));
    } catch (e) {
      _error = e.toString();
      // On simule l'ajout même en cas d'erreur réseau pour la démo
      _machines.add(newMachine);
      success = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }

    return success;
  }

  // 3. Supprimer une machine
  Future<bool> deleteMachine(String machineId) async {
    bool success = false;

    // Garder une copie au cas où l'API échoue
    // On cherche par 'id' OU 'machine_id' pour plus de flexibilité
    final machineIndex = _machines.indexWhere((m) => 
      (m['id']?.toString() == machineId) || (m['machine_id']?.toString() == machineId)
    );
    
    if (machineIndex == -1) return false;

    final removedMachine = _machines[machineIndex];

    // Suppression optimiste UX (immédiatement retiré de la liste)
    _machines.removeAt(machineIndex);
    notifyListeners();

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/machine/$machineId'),
      );
      if (response.statusCode == 200) {
        success = true;
      } else {
        // En cas d'erreur, on remet la machine dans la liste
        _machines.insert(machineIndex, removedMachine);
        _error = "Erreur de suppression: ${response.statusCode}";
      }

      // Simulation asynchrone
      await Future.delayed(const Duration(milliseconds: 500));
      success = true;
    } catch (e) {
      // En cas d'erreur, on remet la machine dans la liste
      _machines.insert(machineIndex, removedMachine);
      _error = e.toString();
    } finally {
      notifyListeners();
    }

    return success;
  }
}
