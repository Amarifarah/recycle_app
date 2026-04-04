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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardPageModel model;
  String selectedPage = "dashboard";

  @override
  void initState() {
    super.initState();
    model = DashboardPageModel();
  }

  @override
  void dispose() {
    model.dispose();
    super.dispose();
  }

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
        return const DashboardHome(); // separate widget, NOT DashboardPage()

      case "clients":
        return ClientsPage();

      case "machines":
        return MachinesPage();

      case "analytics":
        return AnalyticsPage();

      case "settings":
        return SettingsPage();

      case "logout":
        return Center(child: Text("Logout"));

      default:
        return Center(child: Text("Page not found"));
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
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildStatsRow(),
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
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Dashboard",
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
                  _showNotifications();
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
  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
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

  Widget _buildStatsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallCard("Aluminium", "kg", Icons.recycling),
        _smallCard("Plastique", "DA", Icons.attach_money),
        _smallCard("12", "Machines", Icons.memory),
      ],
    );
  }

  Widget _smallCard(String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // 🗺️ MAP FIX

  Widget _buildMapSection() {
    return SizedBox(
      height: 545,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(28.0339, 1.6596), // Algérie
            initialZoom: 5,
          ),
          children: [
            TileLayer(
              urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
              userAgentPackageName:
                  'com.example.recycleapp', // Replace with your app's package name
            ),
            // 📍 MARKERS
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(36.7538, 3.0588), // Alger
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.red),
                ),
                Marker(
                  point: LatLng(35.6911, -0.6417), // Oran
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.blue),
                ),
                Marker(
                  point: LatLng(34.8828, -1.3167), // Tlemcen
                  width: 40,
                  height: 40,
                  child: const Icon(Icons.location_on, color: Colors.green),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
