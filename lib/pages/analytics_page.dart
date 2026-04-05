import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/machinedata_model.dart';
import '../providers/machine_provider.dart';
import '../providers/settings_provider.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MachineProvider>(context, listen: false).fetchMachines();
    });
  }

  List<MachineData> _parseMachines(List<Map<String, dynamic>> rawMachines) {
    List<MachineData> mapped = [];
    for (var machine in rawMachines) {
      double plastic = 0.0;
      double alu = 0.0;
      double totalFill = 0.0;
      double totalCap = 0.0;
      
      if (machine['recyclingBins'] != null) {
        for (var bin in machine['recyclingBins']) {
          double currentFill = (bin['current_fill_kg'] ?? 0).toDouble();
          double cap = (bin['capacity_kg'] ?? 0).toDouble();

          if (bin['type'] == 'PET') plastic += currentFill;
          if (bin['type'] == 'ALU') alu += currentFill;

          totalFill += currentFill;
          totalCap += cap;
        }
      }

      double fillLevel = (totalCap > 0) ? (totalFill / totalCap) : 0.0;
      
      mapped.add(MachineData(
        id: machine['machine_id']?.toString() ?? machine['_id']?.toString() ?? "Inconnu",
        wilaya: machine['city']?.toString() ?? "Inconnu",
        plasticQty: plastic,
        aluminumQty: alu,
        fillLevel: fillLevel,
      ));
    }
    return mapped;
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<MachineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: Theme.of(context).primaryColor)
            );
          }

          final List<MachineData> machines = _parseMachines(provider.machines);

          if (machines.isEmpty) {
            return const Center(child: Text("Aucune machine trouvée."));
          }

          double totalPlastic = machines.fold(0, (sum, m) => sum + m.plasticQty);
          double totalAluminum = machines.fold(0, (sum, m) => sum + m.aluminumQty);
          int fullMachines = machines.where((m) => m.fillLevel > 0.8).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(settings),
                      const SizedBox(height: 32),
                      
                      _buildKpiGrid(context, settings, machines.length, fullMachines, totalPlastic, totalAluminum),
                      
                      const SizedBox(height: 32),
                      
                      _buildPremiumCard(
                        context,
                        title: settings.translate('aluminum') + " & " + settings.translate('plastic'),
                        child: _buildPieChart(settings, totalPlastic, totalAluminum),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      _buildPremiumCard(
                        context,
                        title: "Volume par Wilaya (kg)",
                        child: _buildBarChart(context, machines),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(settings.translate('critical_alerts')),
                      _buildAlerts(context, machines),
                      
                      const SizedBox(height: 32),
                      
                      _buildSectionTitle(settings.translate('detailed_inventory')),
                      _buildDetailedTable(context, machines),
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("EcoVision Analytics", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
    );
  }

  Widget _buildHeaderSection(SettingsProvider settings) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(settings.translate('analytics'), 
          style: GoogleFonts.outfit(fontSize: 28, fontWeight: FontWeight.bold)),
        Text("Données d'exploitation du parc", 
          style: GoogleFonts.readexPro(fontSize: 14, color: Colors.grey[500])),
      ],
    );
  }

  Widget _buildKpiGrid(BuildContext context, SettingsProvider settings, int count, int full, double plastic, double aluminum) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double spacing = 20.0;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            _buildStatCard(context, constraints.maxWidth, settings.translate('total_machines'), count.toString(), "Unités", Icons.sensors, const Color(0xFF3B82F6)),
            _buildStatCard(context, constraints.maxWidth, "À Collecter", full.toString(), "Alerte", Icons.warning_rounded, const Color(0xFFEF4444)),
            _buildStatCard(context, constraints.maxWidth, settings.translate('plastic'), "${plastic.toInt()}kg", "+8% croissance", Icons.eco, const Color(0xFF10B981)),
            _buildStatCard(context, constraints.maxWidth, settings.translate('aluminum'), "${aluminum.toInt()}kg", "Stable", Icons.precision_manufacturing, const Color(0xFFF59E0B)),
          ],
        );
      }
    );
  }

  Widget _buildStatCard(BuildContext context, double maxWidth, String title, String value, String subtitle, IconData icon, Color color) {
    return Container(
      width: (maxWidth - 20) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(blurRadius: 12, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(title, style: GoogleFonts.readexPro(fontSize: 12, color: Colors.grey[500])),
          Text(subtitle, style: GoogleFonts.readexPro(fontSize: 10, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildPremiumCard(BuildContext context, {required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black.withOpacity(0.05), offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(title, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildPieChart(SettingsProvider settings, double plastic, double aluminum) {
    return SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 0,
          centerSpaceRadius: 40,
          sections: [
            PieChartSectionData(
              value: plastic,
              title: settings.translate('plastic'),
              color: const Color(0xFF10B981),
              radius: 50,
              titleStyle: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: aluminum,
              title: settings.translate('aluminum'),
              color: const Color(0xFF3B82F6),
              radius: 45,
              titleStyle: GoogleFonts.readexPro(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(BuildContext context, List<MachineData> machines) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      height: 250,
      child: BarChart(
        BarChartData(
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= machines.length) return const SizedBox();
                  return Text(machines[value.toInt()].wilaya.substring(0, 3), 
                    style: GoogleFonts.readexPro(fontSize: 10, color: Colors.grey));
                },
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
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true, 
                    toY: 100, 
                    color: isDark ? Colors.white10 : const Color(0xFFF1F5F9)
                  ),
                )
              ])
          ],
        ),
      ),
    );
  }

  Widget _buildAlerts(BuildContext context, List<MachineData> machines) {
    final alerts = machines.where((m) => m.fillLevel > 0.8).toList();
    return Column(
      children: alerts.map((m) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
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

  Widget _buildDetailedTable(BuildContext context, List<MachineData> machines) {
    return Column(
      children: machines.map((m) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            SizedBox(
              width: 60, 
              child: Text(
                m.id, 
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Expanded(child: Text(m.wilaya, style: GoogleFonts.readexPro(color: Colors.grey[500]))),
            SizedBox(
              width: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: m.fillLevel,
                  minHeight: 8,
                  color: m.fillLevel > 0.8 ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                  backgroundColor: Theme.of(context).dividerColor.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }
}