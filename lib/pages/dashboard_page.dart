import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycle_app/pages/machines_page.dart';
import '../models/dashboard_model.dart';
import '../widgets/sidebar.dart';
import '../pages/clients_page.dart';
import 'settings_page.dart';
import 'analytics_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../providers/settings_provider.dart';
import '../providers/machine_provider.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPage = "dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SideBar(
            selectedPage: selectedPage,
            onItemSelected: (page) async {
              if (page == 'logout') {
                // Déconnexion complète
                await Provider.of<LoginModel>(context, listen: false).logout();
                if (mounted) {
                  // Retour vers la page de login
                  Navigator.pushReplacementNamed(context, "/login");
                }
              } else {
                setState(() {
                  selectedPage = page;
                });
              }
            },
          ),
          // Contenu
          Expanded(child: getPage()),
        ],
      ),
    );
  }

  Widget getPage() {
    switch (selectedPage) {
      case "dashboard":
        return DashboardHome(key: UniqueKey()); // Force refresh when switching tabs

      case "clients":
        return ClientsPage();

      case "machines":
        return const MachinesPage();

      case "analytics":
        return AnalyticsPage();

      case "settings":
        return SettingsPage();

      case "logout":
        return const Center(child: Text("Logout"));

      default:
        return const Center(child: Text("Page not found"));
    }
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    // Appeler le fetch au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardPageModel>(context, listen: false).fetchStats();
      Provider.of<MachineProvider>(context, listen: false).fetchMachines();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Column(
      children: [
        _buildHeader(context, settings),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildStatsRow(context, settings),
                const SizedBox(height: 20),
                _buildMapSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔔 HEADER
  Widget _buildHeader(BuildContext context, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            settings.translate('dashboard'),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 🔔 Notification button
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications),
                onPressed: () {
                  _showNotifications(context, settings);
                },
              ),

              // 🔴 badge
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 🔔 POPUP NOTIFICATIONS
  void _showNotifications(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: const Text("Notifications"),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                ListTile(
                  leading: Icon(Icons.check_circle, color: Colors.green),
                  title: Text("Nouvelle collecte effectuée"),
                ),
                ListTile(
                  leading: Icon(Icons.warning, color: Colors.orange),
                  title: Text("Machine pleine à Alger"),
                ),
                ListTile(
                  leading: Icon(Icons.info, color: Colors.blue),
                  title: Text("Nouveau client ajouté"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, SettingsProvider settings) {
    final model = Provider.of<DashboardPageModel>(context);

    if (model.isLoading && model.totalMachines == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallCard(
          context,
          "${model.totalAluminum.toStringAsFixed(1)}",
          settings.translate('aluminum') + " (kg)",
          Icons.recycling,
        ),
        _smallCard(
          context,
          "${model.totalPlastic.toStringAsFixed(1)}",
          settings.translate('plastic') + " (kg)",
          Icons.recycling,
        ),
        _smallCard(context, "${model.totalMachines}", settings.translate('machines'), Icons.point_of_sale),
      ],
    );
  }

  Widget _smallCard(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.green),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  // 🗺️ MAP FIX

  Widget _buildMapSection() {
    return SizedBox(
      height: 545,
      child: Consumer<MachineProvider>(
        builder: (context, provider, child) {
          final machines = provider.machines;
          
          return FlutterMap(
            options: MapOptions(
              initialCenter: machines.isNotEmpty 
                  ? LatLng(
                      double.tryParse(machines[0]['latitude']?.toString() ?? '28.0339') ?? 28.0339, 
                      double.tryParse(machines[0]['longitude']?.toString() ?? '1.6596') ?? 1.6596
                    )
                  : LatLng(28.0339, 1.6596), // Algérie par défaut
              initialZoom: machines.isNotEmpty ? 6 : 5,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.recycleapp',
              ),
              // 📍 MARKERS DYNAMIQUES
              MarkerLayer(
                markers: machines.map((m) {
                  final double lat = double.tryParse(m['latitude']?.toString() ?? '0') ?? 0;
                  final double lon = double.tryParse(m['longitude']?.toString() ?? '0') ?? 0;
                  final String rawStatus = (m['status'] ?? 'actif').toString().toLowerCase().trim();
                  
                  // Déterminer la couleur selon le statut (Plus robuste)
                  Color markerColor = Colors.green; // Par défaut Online (actif)
                  if (rawStatus.contains('panne') || rawStatus.contains('maintenance')) {
                    markerColor = Colors.red;
                  } else if (rawStatus.contains('hors ligne') || rawStatus.contains('offline') || rawStatus.contains('inactif')) {
                    markerColor = Colors.orange;
                  }

                  return Marker(
                    point: LatLng(lat, lon),
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: markerColor, size: 30),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
