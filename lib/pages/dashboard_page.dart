import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/dashboard_model.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard_header.dart';
import '../pages/clients_page.dart';
import 'settings_page.dart';

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
            onItemSelected: (page) {
              setState(() {
                selectedPage = page;
              });
            },
          ),
          // Contenu
          Expanded(
            child: selectedPage == "dashboard"
                ? buildDashboardContent()
                : getPage(),
          ),
        ],
      ),
    );
  }

  Widget buildDashboardContent() {
    return SafeArea(
      child: Container(
        color: const Color(0xFFF8FAFC),
        width: double.infinity, // Occupe toute la largeur
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DashboardHeader(),
              const SizedBox(height: 32),

              // ================= KPI SECTION (STRUCTURÉE) =================
              // LayoutBuilder permet de calculer la largeur disponible
              LayoutBuilder(
                builder: (context, constraints) {
                  // On calcule la largeur d'une carte :
                  // (Largeur totale - espacements) / nombre de colonnes
                  double spacing = 20.0;
                  int crossAxisCount = constraints.maxWidth > 1200
                      ? 4
                      : (constraints.maxWidth > 700 ? 2 : 1);
                  double cardWidth =
                      (constraints.maxWidth -
                          (spacing * (crossAxisCount - 1))) /
                      crossAxisCount;

                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      SizedBox(
                        width: cardWidth,
                        child: const DashboardStatCard(
                          value: "2,847",
                          title: "Bouteilles recyclées",
                          subtitle: "+12% cette semaine",
                          icon: Icons.recycling,
                          accentColor: Color(0xFF10B981),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const DashboardStatCard(
                          value: "78%",
                          title: "Taux de remplissage",
                          subtitle: "-2% vs mois dernier",
                          icon: Icons.battery_3_bar_rounded,
                          accentColor: Color(0xFFEF4444),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const DashboardStatCard(
                          value: "24",
                          title: "Machines actives",
                          subtitle: "Stable",
                          icon: Icons.precision_manufacturing,
                          accentColor: Color(0xFF3B82F6),
                        ),
                      ),
                      SizedBox(
                        width: cardWidth,
                        child: const DashboardStatCard(
                          value: "1.2T",
                          title: "Plastique collecté",
                          subtitle: "+8% croissance",
                          icon: Icons.scale,
                          accentColor: Color(0xFFF59E0B),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),

              // ================= MAIN CHART =================
              _buildPremiumCard(
                title: "Évolution des collectes",
                child: SizedBox(
                  height: 320,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          isCurved: true,
                          barWidth: 4,
                          color: const Color(0xFF10B981),
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0x3310B981),
                          ),
                          spots: const [
                            FlSpot(0, 120),
                            FlSpot(1, 300),
                            FlSpot(2, 450),
                            FlSpot(3, 380),
                            FlSpot(4, 600),
                            FlSpot(5, 720),
                            FlSpot(6, 900),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ================= TWO CHARTS GRID =================
              Row(
                children: [
                  Expanded(
                    child: _buildPremiumCard(
                      title: "Bouteilles cette semaine",
                      child: SizedBox(
                        height: 220,
                        child: LineChart(
                          LineChartData(
                            borderData: FlBorderData(show: false),
                            gridData: FlGridData(show: false),
                            lineBarsData: [
                              LineChartBarData(
                                isCurved: true,
                                barWidth: 3,
                                color: const Color(0xFF3B82F6),
                                spots: const [
                                  FlSpot(0, 50),
                                  FlSpot(1, 70),
                                  FlSpot(2, 100),
                                  FlSpot(3, 80),
                                  FlSpot(4, 120),
                                  FlSpot(5, 90),
                                  FlSpot(6, 150),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPremiumCard(
                      title: "Répartition des matériaux",
                      child: SizedBox(
                        height: 220,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                color: const Color(0xFF10B981),
                                value: 65,
                                title: "Plastique",
                              ),
                              PieChartSectionData(
                                color: const Color(0xFF3B82F6),
                                value: 35,
                                title: "Aluminium",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ================= TRANSACTIONS + MAINTENANCE =================
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _buildPremiumCard(
                      title: "Transactions récentes",
                      child: Column(
                        children: model.transactions
                            .map(
                              (t) => _buildTransactionTile(
                                t['name'],
                                t['desc'],
                                t['time'],
                                t['color'],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildPremiumCard(
                      title: "Planning maintenance",
                      child: Column(
                        children: model.maintenance
                            .map(
                              (m) => _buildMaintenanceTile(
                                m['machine'],
                                m['time'],
                                m['color'],
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- WIDGETS ----------------
  Widget _buildPremiumCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Color(0x14000000),
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStatProgress({
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.readexPro(fontSize: 14, color: Colors.black87),
            ),
            Text(
              value,
              style: GoogleFonts.readexPro(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTransactionTile(
    String name,
    String desc,
    String time,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 16,
                child: const Icon(Icons.person, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    desc,
                    style: GoogleFonts.readexPro(color: color, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          Text(
            time,
            style: GoogleFonts.readexPro(color: Colors.grey[600], fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMaintenanceTile(String machine, String time, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                machine,
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
              Text(
                time,
                style: GoogleFonts.readexPro(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildMapStatus(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: GoogleFonts.readexPro(color: Colors.white, fontSize: 12),
      ),
    );
  }

  Widget getPage() {
    switch (selectedPage) {
      case "clients":
        return ClientsPage();

      case "machines":
        return Center(child: Text("Page Machines"));

      case "analytics":
        return Center(child: Text("Page Analytics"));

      case "settings":
        return SettingsPage();

      case "logout":
        return Center(child: Text("Logout"));

      default:
        return buildDashboardContent();
    }
  }
}

class DashboardStatCard extends StatelessWidget {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;

  const DashboardStatCard({
    super.key,
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      //height: 130,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x1A000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 30),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: GoogleFonts.outfit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A365D),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: GoogleFonts.readexPro(
                  fontSize: 12,
                  color: const Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.readexPro(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatefulWidget {
  @override
  State<_PeriodSelector> createState() => _PeriodSelectorState();
}

class _PeriodSelectorState extends State<_PeriodSelector> {
  String selected = "Semaine";

  @override
  Widget build(BuildContext context) {
    final options = ["Jour", "Semaine", "Mois"];

    return Row(
      children: options.map((label) {
        final isSelected = selected == label;

        return Padding(
          padding: const EdgeInsets.only(left: 8),
          child: ChoiceChip(
            label: Text(
              label,
              style: GoogleFonts.readexPro(
                fontSize: 12,
                color: isSelected ? Colors.white : const Color(0xFF64748B),
              ),
            ),
            selected: isSelected,
            selectedColor: const Color(0xFF10B981),
            backgroundColor: const Color(0xFFF1F5F9),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
            onSelected: (_) {
              setState(() {
                selected = label;
              });
            },
          ),
        );
      }).toList(),
    );
  }
}
