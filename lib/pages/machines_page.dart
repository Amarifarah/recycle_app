import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/machine_provider.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  final Color darkGreen = const Color(0xFF1E591E);

  List<Map<String, dynamic>> machines = [
    {
      "id": "M001",
      "name": "RM-Alpha",
      "wilaya": "Alger",
      "capacity": "500",
      "types": ["Plastique", "Aluminium"],
      "status": "online",
      "modelAccuracy": 0.94,
      "bacsInfo": {
        "Plastique": {"fillLevel": 0.85, "lastEmptied": "Aujourd'hui, 08:30"},
        "Aluminium": {"fillLevel": 0.20, "lastEmptied": "Hier, 14:15"},
      },
    },
    {
      "id": "M002",
      "name": "RM-Beta",
      "wilaya": "Oran",
      "capacity": "800",
      "types": ["Carton", "Verre"],
      "status": "offline",
      "modelAccuracy": 0.88,
      "bacsInfo": {
        "Carton": {"fillLevel": 0.10, "lastEmptied": "Aujourd'hui, 06:00"},
        "Verre": {"fillLevel": 0.05, "lastEmptied": "Hier, 18:45"},
      },
    },
    {
      "id": "M003",
      "name": "RM-Gamma",
      "wilaya": "Annaba",
      "capacity": "1000",
      "types": ["Plastique", "Carton", "Aluminium"],
      "status": "maintenance",
      "modelAccuracy": 0.0,
      "bacsInfo": {
        "Plastique": {"fillLevel": 0.50, "lastEmptied": "Il y a 2 jours"},
        "Carton": {"fillLevel": 0.95, "lastEmptied": "Il y a 3 jours"},
        "Aluminium": {"fillLevel": 0.80, "lastEmptied": "Il y a 2 jours"},
      },
    },
  ];
  String searchQuery = "";
  String statusFilter = "Tous"; // New status filter

  // Variables d'erreurs
  String? idError,
      nameError,
      typeError,
      wilayaError,
      capacityError,
      accuracyError,
      latError,
      lonError,
      locationError,
      sizeError;
  final List<String> typeOptions = [
    "Aluminium",
    "Verre",
    "Carton",
    "Plastique",
  ];
  List<String> selectedTypes = [];
  String? machineLocation;
  String? machineSize;

  final List<String> locationOptions = [
    "Institut",
    "Restaurant",
    "Centre commercial",
    "Espace public",
    "Usine",
  ];

  final List<String> sizeOptions = ["Petit", "Grand"];

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController latController = TextEditingController();
  final TextEditingController lonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MachineProvider>(
        context,
        listen: false,
      ).setInitialMachines(machines);
    });
  }

  // --- DIALOGUE DE CONFIRMATION PERSONNALISÉ ---
  void _showDeleteDialog(int index, String machineId, String machineName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 60,
                ),
                const SizedBox(height: 15),
                Text(
                  "Supprimer la machine ?",
                  style: GoogleFonts.lato(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Voulez-vous vraiment supprimer $machineName ? Cette action est irréversible.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Annuler",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: () {
                          Provider.of<MachineProvider>(
                            context,
                            listen: false,
                          ).deleteMachine(machineId);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Supprimer",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleSave(StateSetter setModalState) async {
    setModalState(() {
      idError =
          (idController.text.isEmpty || int.tryParse(idController.text) == null)
          ? "ID numérique requis"
          : null;
      nameError = nameController.text.trim().isEmpty ? "Nom obligatoire" : null;

      latError =
          (latController.text.isEmpty ||
              double.tryParse(latController.text) == null)
          ? "Latitude invalide"
          : null;
      lonError =
          (lonController.text.isEmpty ||
              double.tryParse(lonController.text) == null)
          ? "Longitude invalide"
          : null;
      locationError = (machineLocation == null)
          ? "Choisissez l'emplacement"
          : null;
      sizeError = (machineSize == null) ? "Choisissez la taille" : null;
    });

    if (idError == null &&
        nameError == null &&
        latError == null &&
        lonError == null &&
        locationError == null &&
        sizeError == null) {

      final newMachine = {
        "machine_id": idController.text,
        "name": nameController.text,
        "latitude": double.parse(latController.text),
        "longitude": double.parse(lonController.text),
        "status": "actif",
      };

      bool success = await Provider.of<MachineProvider>(
        context,
        listen: false,
      ).addMachine(newMachine);

      if (success && mounted) {
        _clearInputs();
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Machine ajoutée avec succès !"),
            backgroundColor: Colors.green,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Erreur lors de l'ajout de la machine"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearInputs() {
    idController.clear();
    nameController.clear();
    selectedTypes.clear();
    machineLocation = null;
    machineSize = null;
    latController.clear();
    lonController.clear();
  }

  void _showAddMachineDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.70,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text(
                  "Ajouter une Machine",
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: darkGreen,
                  ),
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildField(
                          idController,
                          "ID Machine",
                          Icons.fingerprint,
                          idError,
                          isNum: true,
                        ),
                        _buildField(
                          nameController,
                          "Nom",
                          Icons.settings,
                          nameError,
                        ),

                        // Coordonnées
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                latController,
                                "Latitude",
                                Icons.location_on,
                                latError,
                                isNum: true,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildField(
                                lonController,
                                "Longitude",
                                Icons.location_on,
                                lonError,
                                isNum: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: machineSize,
                          decoration: InputDecoration(
                            labelText: "Type de Machine",
                            prefixIcon: const Icon(Icons.aspect_ratio),
                            errorText: sizeError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: sizeOptions
                              .map(
                                (s) =>
                                    DropdownMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => machineSize = val),
                        ),
                        const SizedBox(height: 15),

                        DropdownButtonFormField<String>(
                          value: machineLocation,
                          decoration: InputDecoration(
                            labelText: "Emplacement",
                            prefixIcon: const Icon(Icons.place),
                            errorText: locationError,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: locationOptions
                              .map(
                                (l) =>
                                    DropdownMenuItem(value: l, child: Text(l)),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setModalState(() => machineLocation = val),
                        ),
                        const SizedBox(height: 15),


                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: darkGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: () => _handleSave(setModalState),
                    child: const Text(
                      "ENREGISTRER",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon,
    String? err, {
    bool isNum = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          errorText: err,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _showMachineDetailsDialog(Map<String, dynamic> machine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        double accuracy = machine['modelAccuracy'] ?? 0.0;

        Color statusColor = Colors.grey;
        String statusText = "Inconnu";
        if (machine['status'] == 'actif') {
          statusColor = Colors.green;
          statusText = "En Ligne";
        } else if (machine['status'] == 'inactif') {
          statusColor = Colors.orange;
          statusText = "Hors Ligne";
        } else if (machine['status'] == 'en_panne') {
          statusColor = Colors.red;
          statusText = "En Panne";
        }

        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.70,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Gestion: ${machine['name']}",
                          style: GoogleFonts.lato(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: darkGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text("ID: ${machine['machine_id'] ?? machine['id']} | 📍 Lat: ${machine['latitude']} | Lon: ${machine['longitude']}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: statusColor.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Provider-Ready AI Model Stats
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.white],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.psychology,
                        color: Colors.blue,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Précision du Modèle IA",
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Modèle de tri optique actif",
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "${(accuracy * 100).toStringAsFixed(1)}%",
                      style: GoogleFonts.lato(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text(
                    "Fermer la vue de gestion",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final providerMachines = Provider.of<MachineProvider>(context).machines;

    final filtered = providerMachines.where((m) {
      final matchesSearch = (m['name']?.toString() ?? '').toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      bool matchesStatus = true;
      if (statusFilter == "En ligne" && m['status'] != 'actif') {
        matchesStatus = false;
      }
      if (statusFilter == "Hors ligne" && m['status'] != 'inactif') {
        matchesStatus = false;
      }
      if (statusFilter == "En panne" && m['status'] != 'en_panne') {
        matchesStatus = false;
      }

      return matchesSearch && matchesStatus;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Parc Machines",
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Rechercher une machine...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Status Filters
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ["Tous", "En ligne", "Hors ligne", "En panne"].map((
                  status,
                ) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(status),
                      selected: statusFilter == status,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() => statusFilter = status);
                        }
                      },
                      selectedColor: darkGreen.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: statusFilter == status
                            ? darkGreen
                            : Colors.black87,
                        fontWeight: statusFilter == status
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _showAddMachineDialog,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text(
                "AJOUTER UNE MACHINE",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: darkGreen,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];

                  // Status Logic
                  Color statusColor = Colors.grey;
                  if (m['status'] == 'actif') {
                    statusColor = Colors.green;
                  } else if (m['status'] == 'inactif') {
                    statusColor = Colors.orange;
                  } else if (m['status'] == 'en_panne') {
                    statusColor = Colors.red;
                  }

                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: Stack(
                        children: [
                          CircleAvatar(
                            backgroundColor: darkGreen.withValues(alpha: 0.1),
                            child: Icon(
                              Icons.precision_manufacturing,
                              color: darkGreen,
                            ),
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      title: Text(
                        "${m['name']} (ID: ${m['machine_id'] ?? m['id']})",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text("📍 Lat: ${m['latitude']} | Lon: ${m['longitude']}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ElevatedButton(
                            onPressed: () => _showMachineDetailsDialog(m),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.withValues(
                                alpha: 0.1,
                              ),
                              foregroundColor: Colors.blue,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: const Text(
                              "Consulter",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.redAccent,
                            ),
                            onPressed: () {
                              final realIndex = providerMachines.indexOf(m);
                              if (realIndex != -1)
                                _showDeleteDialog(
                                  realIndex,
                                  m['id'],
                                  m['name'],
                                );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
