import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/machinedata_model.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<MachineData> machines = [
      MachineData(id: "M001", wilaya: "Sidi Bel Abbès", plasticQty: 45.5, aluminumQty: 20.0, fillLevel: 0.85),
      MachineData(id: "M002", wilaya: "Oran", plasticQty: 30.2, aluminumQty: 15.5, fillLevel: 0.40),
      MachineData(id: "M003", wilaya: "Alger", plasticQty: 60.8, aluminumQty: 40.2, fillLevel: 0.95),
    ];

    double totalPlastic = machines.fold(0, (sum, m) => sum + m.plasticQty);
    double totalAluminum = machines.fold(0, (sum, m) => sum + m.aluminumQty);
    int fullMachines = machines.where((m) => m.fillLevel > 0.8).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Même fond que le dashboard
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeaderSection(),
                  const SizedBox(height: 32),
                  
                  // KPI Section identique au dashboard
                  _buildKpiGrid(machines.length, fullMachines, totalPlastic, totalAluminum),
                  
                  const SizedBox(height: 32),
                  
                  // Graphique Principal (Évolution/Répartition)
                  _buildPremiumCard(
                    title: "Répartition des Matières",
                    child: _buildPieChart(totalPlastic, totalAluminum),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Performance par Wilaya (Bar Chart style Premium)
                  _buildPremiumCard(
                    title: "Volume par Wilaya (kg)",
                    child: _buildBarChart(machines),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle("Alertes Critiques"),
                  _buildAlerts(machines),
                  
                  const SizedBox(height: 32),
                  
                  _buildSectionTitle("Inventaire Détaillé"),
                  _buildDetailedTable(machines),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- COMPOSANTS UI HARMONISÉS ---

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFFF8FAFC),
      flexibleSpace: FlexibleSpaceBar(
        title: Text("EcoVision Analytics", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: const Color(0xFF1E293B))),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Analyses Détaillées", 
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
        Text("Données d'exploitation du parc ENIE", 
          style: GoogleFonts.readexPro(fontSize: 14, color: const Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildKpiGrid(int count, int full, double plastic, double aluminum) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 20.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _buildStatCard(constraints.maxWidth, "Total Machines", count.toString(), "Unités", Icons.sensors, const Color(0xFF3B82F6)),
            _buildStatCard(constraints.maxWidth, "À Collecter", full.toString(), "Alerte", Icons.warning_rounded, const Color(0xFFEF4444)),
            _buildStatCard(constraints.maxWidth, "Plastique", "${plastic.toInt()}kg", "+8% croissance", Icons.eco, const Color(0xFF10B981)),
            _buildStatCard(constraints.maxWidth, "Aluminium", "${aluminum.toInt()}kg", "Stable", Icons.precision_manufacturing, const Color(0xFFF59E0B)),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(double maxWidth, String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      width: (maxWidth - 20) / 2, // Grid 2x2
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(blurRadius: 12, color: Color(0x1A000000), offset: Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold, color: const Color(0xFF1A365D))),
          Text(title, style: GoogleFonts.readexPro(fontSize: 12, color: const Color(0xFF64748B))),
          Text(subtitle, style: GoogleFonts.readexPro(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildPremiumCard({required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [BoxShadow(blurRadius: 20, color: Color(0x14000000), offset: Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B))),
    );
  }

  // --- GRAPHIQUES IDENTIQUES AU DASHBOARD ---

  Widget _buildPieChart(double plastic, double aluminum) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: plastic,
              title: 'Plastique',
              color: const Color(0xFF10B981),
              radius: 50,
              titleStyle: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: aluminum,
              title: 'Alu',
              color: const Color(0xFF3B82F6),
              radius: 45,
              titleStyle: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<MachineData> machines) {
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) => Text(machines[value.toInt()].wilaya.substring(0, 3), 
                  style: GoogleFonts.readexPro(fontSize: 10, color: Colors.grey)),
              ),
            ),
          ),
          barGroups: [
            for (int i = 0; i < machines.length; i++)
              BarChartGroupData(x: i, barRods: [
                BarChartRodData(
                  toY: machines[i].plasticQty + machines[i].aluminumQty,
                  color: const Color(0xFF10B981),
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  backDrawRodData: BackgroundBarChartRodData(show: true, toY: 100, color: const Color(0xFFF1F5F9)),
                )
              ])
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(List<MachineData> machines) {
    final alerts = machines.where((m) => m.fillLevel > 0.8).toList();
    return Column(
      children: alerts.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFEE2E2)),
        ),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFEF4444), radius: 16, child: Icon(Icons.bolt, color: Colors.white, size: 16)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Critique : ${m.id}", style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
                  Text("Collecte urgente à ${m.wilaya}", style: GoogleFonts.readexPro(fontSize: 12, color: Colors.grey[600])),
                ],
              ),
            ),
            Text("${(m.fillLevel * 100).toInt()}%", 
              style: GoogleFonts.outfit(color: const Color(0xFFEF4444), fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      )).toList(),
    );
  }

  Widget _buildDetailedTable(List<MachineData> machines) {
    return _buildPremiumCard(
      title: "Statut par Machine",
      child: Column(
        children: machines.map((m) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              SizedBox(width: 50, child: Text(m.id, style: GoogleFonts.outfit(fontWeight: FontWeight.w600))),
              Expanded(child: Text(m.wilaya, style: GoogleFonts.readexPro(color: const Color(0xFF64748B)))),
              SizedBox(
                width: 120,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: m.fillLevel,
                    minHeight: 8,
                    color: m.fillLevel > 0.8 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
              ),
            ],
          ),
        )).toList(),
      ),
    );
  }
}