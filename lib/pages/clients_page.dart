import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/clients_model.dart';
import '../providers/settings_provider.dart';

class ClientsPage extends StatefulWidget {
  const ClientsPage({super.key});

  @override
  State<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends State<ClientsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus = "Actif"; // Filtre par défaut

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    // 1. LOGIQUE DE FILTRAGE
    List<Client> filteredClients = clientsMock.where((c) {
      final query = _searchController.text.toLowerCase();
      final matchesQuery =
          c.name.toLowerCase().contains(query) ||
          c.email.toLowerCase().contains(query);
      final matchesStatus =
          _selectedStatus == null || c.status == _selectedStatus;
      return matchesQuery && matchesStatus;
    }).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(context, settings),

            // --- BARRE DE FILTRES ---
            _buildFilterBar(context, settings),

            // --- TABLEAU DES CLIENTS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        _buildTableHeader(context),
                        Expanded(
                          child: filteredClients.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: filteredClients.length,
                                  itemBuilder: (context, index) {
                                    return _buildClientRow(
                                      context,
                                      filteredClients[index],
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS COMPOSANTS ---

  Widget _buildHeader(BuildContext context, SettingsProvider settings) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  settings.translate('client_management'),
                  style: GoogleFonts.outfit(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Supervision et analyse des utilisateurs',
                  style: TextStyle(color: Colors.grey[500], fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            children: [
              _buildExportButton(
                "CSV",
                Icons.file_download_outlined,
                const Color(0xFF059669),
                const Color(0xFFF0FDF4).withOpacity(0.1),
              ),
              const SizedBox(width: 12),
              _buildExportButton(
                "PDF",
                Icons.picture_as_pdf_outlined,
                const Color(0xFF1D4ED8),
                const Color(0xFFEFF6FF).withOpacity(0.1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExportButton(
    String label,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return SizedBox(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 18, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          elevation: 0,
          side: BorderSide(color: color.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, SettingsProvider settings) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 45,
              child: TextFormField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: settings.translate('search'),
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 20,
                  ),
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF10B981),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          _buildDropdownStatus(context),
        ],
      ),
    );
  }

  Widget _buildDropdownStatus(BuildContext context) {
    return Container(
      width: 160,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: const Icon(Icons.filter_list, size: 18),
          dropdownColor: Theme.of(context).cardColor,
          items: ['Actif', 'Inactif', 'Suspendu'].map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val),
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context) {
    final Color textColor = Theme.of(context).textTheme.bodySmall!.color!;
    return Container(
      color: Theme.of(context).dividerColor.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'CLIENT',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'EMAIL',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'BOUTEILLES',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'POIDS (KG)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'POINTS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'INSCRIPTION',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildClientRow(BuildContext context, Client client) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.5))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).dividerColor,
                  radius: 18,
                  child: const Icon(Icons.person, size: 20, color: Colors.grey),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      Text(
                        "ID: ${client.id}",
                        style: TextStyle(color: Colors.grey[500], fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              client.email,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          Expanded(
            child: _buildBadge("${client.bottles}", const Color(0xFF10B981)),
          ),
          Expanded(
            child: _buildBadge("${client.weight}", const Color(0xFF3B82F6)),
          ),
          Expanded(
            child: _buildBadge("${client.points}", const Color(0xFFF59E0B)),
          ),
          Expanded(
            child: Text(
              client.registrationDate,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Text(
          text,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            "Aucun client trouvé",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}

