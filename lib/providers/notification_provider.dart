import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationProvider with ChangeNotifier {
  // Notifications non traitées ("envoyées") — affichées sur le Dashboard
  List<dynamic> _pendingNotifications = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get pendingNotifications => _pendingNotifications;

  // Compatibilité avec l'ancien code (Consumer<NotificationProvider> qui utilise .notifications)
  List<dynamic> get notifications => _pendingNotifications;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Badge = nombre de notifications non traitées
  int get unreadCount => _pendingNotifications.length;

  final String baseUrl = "https://rvm-backend-oaot.onrender.com";

  // 1. Récupérer uniquement les notifications non traitées (statut "envoyée") → Dashboard
  Future<void> fetchPendingNotifications() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/notif/admin/envoyees'));
      if (response.statusCode == 200) {
        _pendingNotifications = json.decode(response.body);
      } else {
        _error = "Erreur: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau: $e";
      print("Erreur fetchPendingNotifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alias pour la compatibilité avec l'ancien code
  Future<void> fetchNotifications() => fetchPendingNotifications();

  // 2. Récupérer l'historique complet des notifications d'une machine spécifique
  Future<List<dynamic>> fetchMachineHistory(String machineId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/notif/machine/$machineId'));
      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      }
    } catch (e) {
      print("Erreur fetchMachineHistory ($machineId): $e");
    }
    return [];
  }

  // 3. Marquer une notification comme traitée → la retire IMMÉDIATEMENT du Dashboard
  Future<bool> markAsRead(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/notif/status/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"status": "lue"}),
      );
      if (response.statusCode == 200) {
        _pendingNotifications.removeWhere((n) => n['_id'] == id);
        notifyListeners();
        return true;
      }
    } catch (e) {
      print("Erreur markAsRead: $e");
    }
    return false;
  }
}
