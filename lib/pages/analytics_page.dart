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
  String _selectedPeriod = '7D'; // Options: '1D', '7D', '30D'
  String _selectedCity = 'All';  // Options: 'All', 'Oran', 'Alger', etc.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = Provider.of<MachineProvider>(context, listen: false);
      p.fetchMachines();
      p.fetchRecycledProducts();
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

          final List<MachineData> machines = _parseMachines(provider.machines)
              .where((m) => _selectedCity == 'All' || m.wilaya == _selectedCity)
              .toList();

          if (machines.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Aucune machine trouvée."),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      provider.fetchMachines();
                      provider.fetchRecycledProducts();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("Réessayer"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  ),
                ],
              ),
            );
          }

          double totalPlastic = machines.fold(0, (sum, m) => sum + m.plasticQty);
          double totalAluminum = machines.fold(0, (sum, m) => sum + m.aluminumQty);
          int fullMachines = machines.where((m) => m.fillLevel > 0.8).length;

          return CustomScrollView(
            slivers: [
              _buildAppBar(context, machines, provider.machines),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeaderSection(settings),
                      const SizedBox(height: 24),
                      _buildFilterBar(context, settings),
                      const SizedBox(height: 32),
                      
                      _buildKpiGrid(context, settings, machines.length, fullMachines, totalPlastic, totalAluminum),
                      
                      const SizedBox(height: 32),
                      
                      _buildPremiumCard(
                        context,
                        title: "Tendance de Recyclage (7 derniers jours)",
                        child: _buildTrendChart(context, provider.recycledProducts),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      Row(
                        children: [
                          Expanded(
                            child: _buildPremiumCard(
                              context,
                              title: settings.translate('recyc_distribution'),
                              child: _buildPieChart(settings, totalPlastic, totalAluminum),
                            ),
                          ),
                        ],
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

  Widget _buildAppBar(BuildContext context, List<MachineData> machines, List<Map<String, dynamic>> rawMachines) {
    // Liste exhaustive des Wilayas d'Algérie
    final allWilayas = [
      'All', 'Adrar', 'Chlef', 'Laghouat', 'Oum El Bouaghi', 'Batna', 'Béjaïa', 'Biskra', 
      'Béchar', 'Blida', 'Bouira', 'Tamanrasset', 'Tébessa', 'Tlemcen', 'Tiaret', 'Tizi Ouzou', 
      'Alger', 'Djelfa', 'Jijel', 'Sétif', 'Saïda', 'Skikda', 'Sidi Bel Abbès', 'Annaba', 
      'Guelma', 'Constantine', 'Médéa', 'Mostaganem', 'M\'Sila', 'Mascara', 'Ouargla', 'Oran', 
      'El Bayadh', 'Illizi', 'Bordj Bou Arreridj', 'Boumerdès', 'El Tarf', 'Tindouf', 
      'Tissemsilt', 'El Oued', 'Khenchela', 'Souk Ahras', 'Tipaza', 'Mila', 'Aïn Defla', 
      'Naâma', 'Aïn Témouchent', 'Ghardaïa', 'Relizane', 'Timimoun', 'Bordj Badji Mokhtar', 
      'Ouled Djellal', 'Béni Abbès', 'In Salah', 'In Guezzam', 'Touggourt', 'Djanet', 
      'El M\'Ghair', 'El Meniaâ', 'Aflou', 'El Abiodh Sidi Cheikh', 'El Aricha', 'El Kantara', 
      'Barika', 'Bou Saâda', 'Bir El Ater', 'Ksar El Boukhari', 'Ksar Chellala', 'Aïn Oussera', 'Messaad'
    ];
    
    return SliverAppBar(
      expandedHeight: 80.0,
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      flexibleSpace: FlexibleSpaceBar(
        title: Text("EcoVision Analytics", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color)),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.green),
          onPressed: () {
            final p = context.read<MachineProvider>();
            p.fetchMachines();
            p.fetchRecycledProducts();
          },
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCity,
              icon: const Icon(Icons.location_on, size: 18, color: Colors.green),
              style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold),
              onChanged: (String? newValue) {
                if (newValue != null) setState(() => _selectedCity = newValue);
              },
              items: allWilayas.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, SettingsProvider settings) {
    final periods = ['1D', '7D', '30D'];
    final labels = {'1D': 'Aujourd\'hui', '7D': '7 Jours', '30D': '30 Jours'};

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: periods.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final p = periods[index];
          final isSelected = _selectedPeriod == p;
          return FilterChip(
            label: Text(labels[p]!),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() => _selectedPeriod = p);
            },
            selectedColor: Colors.green.withOpacity(0.2),
            checkmarkColor: Colors.green,
            labelStyle: GoogleFonts.readexPro(
              fontSize: 12, 
              color: isSelected ? Colors.green : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? Colors.green : Colors.transparent)),
          );
        },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      width: (maxWidth - 20) / 2,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark 
            ? [color.withOpacity(0.15), color.withOpacity(0.05)]
            : [color.withOpacity(0.1), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            blurRadius: 15, 
            color: color.withOpacity(0.05), 
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(value, 
            style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
          const SizedBox(height: 4),
          Text(title, 
            style: GoogleFonts.readexPro(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(subtitle, 
              style: GoogleFonts.readexPro(fontSize: 10, fontWeight: FontWeight.bold, color: color)),
          ),
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
      height: 200,
      child: PieChart(
        PieChartData(
          sectionsSpace: 4,
          centerSpaceRadius: 50,
          sections: [
            PieChartSectionData(
              value: plastic,
              title: "${((plastic / (plastic + aluminum + 0.1)) * 100).toInt()}%",
              color: const Color(0xFF10B981),
              radius: 20,
              showTitle: true,
              titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            PieChartSectionData(
              value: aluminum,
              title: "${((aluminum / (plastic + aluminum + 0.1)) * 100).toInt()}%",
              color: const Color(0xFF3B82F6),
              radius: 20,
              showTitle: true,
              titleStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendChart(BuildContext context, List<Map<String, dynamic>> products) {
    if (products.isEmpty) {
      return Container(
        height: 200,
        alignment: Alignment.center,
        child: Text("Aucun historique pour le moment", style: TextStyle(color: Colors.grey[400])),
      );
    }

    // Extraction des points réels basés sur le poids des produits recyclés
    List<FlSpot> spots = [];
    for (int i = 0; i < products.length; i++) {
      double weight = (products[i]['weight_kg'] ?? 0).toDouble();
      spots.add(FlSpot(i.toDouble(), weight));
    }
    
    // Si un seul point, on en ajoute un à 0 pour faire une ligne
    if (spots.length == 1) {
      spots.insert(0, const FlSpot(0, 0));
    }

    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1)),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: const Color(0xFF10B981),
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: const Color(0xFF10B981).withOpacity(0.1),
              ),
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