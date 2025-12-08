import 'package:flutter/material.dart';
import '../models/dashboard_model.dart';
import '../widgets/sidebar.dart'; // 🔥 AJOUT

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late DashboardModel model;
  String selectedPage = "dashboard"; // 🔥 Page active

  @override
  void initState() {
    super.initState();
    model = DashboardModel();
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
          // ---------------- SIDEBAR ----------------
          SideBar(
            selectedPage: selectedPage,
            onItemSelected: (page) {
              setState(() {
                selectedPage = page;
              });
            },
          ),

          // ---------------- CONTENU ----------------
          Expanded(
            child: selectedPage == "dashboard"
                ? buildDashboardContent() // Page dashboard (celle que tu avais)
                : getPage(), // Autres pages (machines, clients, etc.)
          ),
        ],
      ),
    );
  }

  // ------ PAGE DYNAMIQUE ------
  Widget getPage() {
    switch (selectedPage) {
      case "machines":
        return const Center(
          child: Text("PAGE MACHINES", style: TextStyle(fontSize: 26)),
        );

      case "clients":
        return const Center(
          child: Text("PAGE CLIENTS", style: TextStyle(fontSize: 26)),
        );

      case "analytics":
        return const Center(
          child: Text("PAGE ANALYTICS", style: TextStyle(fontSize: 26)),
        );

      case "settings":
        return const Center(
          child: Text("PAGE PARAMÈTRES", style: TextStyle(fontSize: 26)),
        );

      default:
        return buildDashboardContent();
    }
  }

  // -------------------------------------------------------------------------
  // --------------------- TON DASHBOARD ORIGINAL ICI ------------------------
  // -------------------------------------------------------------------------
  Widget buildDashboardContent() {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      appBar: AppBar(
        elevation: 1,
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF2E7D32), Colors.green],
                ),
              ),
              child: const Icon(Icons.eco_rounded, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Text(
              "EcoVision Dashboard",
              style: TextStyle(
                color: Color(0xFF2E7D32),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: const [
          Icon(Icons.notifications_none, color: Colors.black87),
          SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.green,
            child: Icon(Icons.person, color: Colors.white),
          ),
          SizedBox(width: 16),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // -------- STAT CARDS --------
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ValueListenableBuilder<int>(
                  valueListenable: model.machinesActives,
                  builder: (_, value, __) => StatCard(
                    title: "Machines actives",
                    value: "$value",
                    icon: Icons.settings_input_component,
                    color: Colors.green,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: model.machinesEnPanne,
                  builder: (_, value, __) => StatCard(
                    title: "En panne",
                    value: "$value",
                    icon: Icons.error_outline,
                    color: Colors.red,
                  ),
                ),
                ValueListenableBuilder<int>(
                  valueListenable: model.tauxRecyclage,
                  builder: (_, value, __) => StatCard(
                    title: "Taux recyclé",
                    value: "$value%",
                    icon: Icons.recycling,
                    color: Color(0xFF4FC3F7),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            // -------- GRAPH PLACEHOLDER --------
            Container(
              width: double.infinity,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 12,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  "Graphique de monitoring\n(à intégrer plus tard)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // -------- MACHINE LIST TITLE --------
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Machines",
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            const MachineTile(
              name: "Machine X12",
              status: "Active",
              color: Colors.green,
              percent: 0.90,
            ),
            const MachineTile(
              name: "Machine B07",
              status: "Maintenance",
              color: Colors.orange,
              percent: 0.55,
            ),
            const MachineTile(
              name: "Machine C03",
              status: "En panne",
              color: Colors.red,
              percent: 0.20,
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- STAT CARD (inchangé) ----------------
class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------- MACHINE TILE ----------------
class MachineTile extends StatelessWidget {
  final String name;
  final String status;
  final Color color;
  final double percent;

  const MachineTile({
    super.key,
    required this.name,
    required this.status,
    required this.color,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color, radius: 8),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(status, style: TextStyle(color: color, fontSize: 14)),
              ],
            ),
          ),

          SizedBox(
            width: 70,
            child: LinearProgressIndicator(
              value: percent,
              color: color,
              backgroundColor: Colors.grey.shade200,
            ),
          ),
        ],
      ),
    );
  }
}
