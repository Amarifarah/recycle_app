import 'package:flutter/material.dart';

class DashboardModel {
  // Exemple : controllers ou states
  final ValueNotifier<int> machinesActives = ValueNotifier(12);
  final ValueNotifier<int> machinesEnPanne = ValueNotifier(3);
  final ValueNotifier<int> tauxRecyclage = ValueNotifier(78);

  void dispose() {
    machinesActives.dispose();
    machinesEnPanne.dispose();
    tauxRecyclage.dispose();
  }
}
