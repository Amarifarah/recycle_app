import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationProvider with ChangeNotifier {
  List<dynamic> _notifications = [];
  bool _isLoading = false;
  String? _error;

  List<dynamic> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Nombre de notifications non lues (statut DIFFERENT de "lue")
  int get unreadCount => _notifications.where((n) => n['status'] != 'lue').length;

  final String allNotifUrl = "https://rvm-backend-oaot.onrender.com/notif/admin";
  final String statusUrl = "https://rvm-backend-oaot.onrender.com/notif/status";

  // 1. Récupérer TOUTES les notifications (Historique complet)
  Future<void> fetchNotifications() async {
    _isLoading = true;
    try {
      final response = await http.get(Uri.parse(allNotifUrl));
      if (response.statusCode == 200) {
        _notifications = json.decode(response.body);
      } else {
        _error = "Erreur: ${response.statusCode}";
      }
    } catch (e) {
      _error = "Erreur réseau: $e";
      print("Erreur fetch notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Marquer comme traitée (lue)
  Future<bool> markAsRead(String id) async {
    try {
      final response = await http.put(
        Uri.parse('$statusUrl/$id'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({"status": "lue"}),
      );
      
      if (response.statusCode == 200) {
        // Mise à jour locale immédiate pour fluidité UI
        int index = _notifications.indexWhere((n) => n['_id'] == id);
        if (index != -1) {
          _notifications[index]['status'] = 'lue';
          _notifications[index]['updated_at'] = DateTime.now().toIso8601String();
          notifyListeners();
        }
        return true;
      }
    } catch (e) {
      print("Erreur markAsRead: $e");
    }
    return false;
  }
}
