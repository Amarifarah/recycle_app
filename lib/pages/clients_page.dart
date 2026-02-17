import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/clients_model.dart'; // Assure-toi que ce fichier contient bien la classe Client et clientsMock

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
      backgroundColor: const Color(0xFFF8FAFB),
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            _buildHeader(),

            // --- BARRE DE FILTRES ---
            _buildFilterBar(),

            // --- TABLEAU DES CLIENTS ---
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.08),
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Column(
                      children: [
                        _buildTableHeader(),
                        Expanded(
                          child: filteredClients.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  itemCount: filteredClients.length,
                                  itemBuilder: (context, index) {
                                    return _buildClientRow(
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

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des Clients',
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Supervision et analyse des utilisateurs de recyclage',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              _buildExportButton(
                "CSV",
                Icons.file_download_outlined,
                const Color(0xFF059669),
                const Color(0xFFF0FDF4),
              ),
              const SizedBox(width: 12),
              _buildExportButton(
                "PDF",
                Icons.picture_as_pdf_outlined,
                const Color(0xFF1D4ED8),
                const Color(0xFFEFF6FF),
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
    return Container(
      height: 40,
      child: ElevatedButton.icon(
        onPressed: () => print("Export $label"),
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

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 45,
              child: TextFormField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un client...',
                  hintStyle: const TextStyle(fontSize: 14),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFF6B7280),
                    size: 20,
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
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
          _buildDropdownStatus(),
        ],
      ),
    );
  }

  Widget _buildDropdownStatus() {
    return Container(
      width: 160,
      height: 45,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          icon: const Icon(Icons.filter_list, size: 18),
          style: const TextStyle(
            color: Color(0xFF374151),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          items: ['Actif', 'Inactif', 'Suspendu'].map((e) {
            return DropdownMenuItem(value: e, child: Text(e));
          }).toList(),
          onChanged: (val) => setState(() => _selectedStatus = val),
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'CLIENT',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'EMAIL',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'BOUTEILLES',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'POIDS (KG)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'POINTS',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                'INSCRIPTION',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF4B5563),
                ),
              ),
            ),
          ),
          SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildClientRow(Client client) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE5E7EB),
                  radius: 18,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF111827),
                        ),
                      ),
                      Text(
                        "ID: ${client.id}",
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 11,
                        ),
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
              style: const TextStyle(color: Color(0xFF4B5563), fontSize: 13),
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
              style: const TextStyle(color: Color(0xFF374151), fontSize: 13),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF9CA3AF),
              size: 14,
            ),
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
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
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
