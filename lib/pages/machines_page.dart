import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  String selectedWilaya = "Toutes";
  String searchText = "";
  
  final List<String> wilayas = [
    "Toutes",
    "Adrar (01)", "Chlef (02)", "Laghouat (03)", "Oum El Bouaghi (04)",
    "Batna (05)", "Béjaïa (06)", "Biskra (07)", "Béchar (08)",
    "Blida (09)", "Bouira (10)", "Tamanrasset (11)", "Tébessa (12)",
    "Tlemcen (13)", "Tiaret (14)", "Tizi Ouzou (15)", "Alger (16)",
    "Djelfa (17)", "Jijel (18)", "Sétif (19)", "Saïda (20)",
    "Skikda (21)", "Sidi Bel Abbès (22)", "Annaba (23)", "Guelma (24)",
    "Constantine (25)", "Médéa (26)", "Mostaganem (27)", "M'Sila (28)",
    "Mascara (29)", "Ouargla (30)", "Oran (31)", "El Bayadh (32)",
    "Illizi (33)", "Bordj Bou Arreridj (34)", "Boumerdès (35)",
    "El Tarf (36)", "Tindouf (37)", "Tissemsilt (38)", "El Oued (39)",
    "Khenchela (40)", "Souk Ahras (41)", "Tipaza (42)", "Mila (43)",
    "Aïn Defla (44)", "Naâma (45)", "Aïn Témouchent (46)",
    "Ghardaïa (47)", "Relizane (48)",
    "Timimoun (49)", "Bordj Badji Mokhtar (50)", "Ouled Djellal (51)",
    "Béni Abbès (52)", "In Salah (53)", "In Guezzam (54)",
    "Touggourt (55)", "Djanet (56)", "El M'Ghair (57)", "El Meniaa (58)"
  ];

  // Liste fictive des machines pour l'exemple
  final List<Map<String, dynamic>> machines = [
    {
      "id": "GM-01-ALGER",
      "wilaya": "Alger (16)",
      "commune": "Sidi M'Hamed",
      "status": "En ligne",
      "plastic": 0.85,
      "aluminum": 0.30,
      "ia_accuracy": "98.5%",
      "last_update": "Il y a 2 min"
    },
    {
      "id": "GM-31-ORAN",
      "wilaya": "Oran (31)",
      "commune": "Akid Lotfi",
      "status": "Hors ligne",
      "plastic": 0.10,
      "aluminum": 0.05,
      "ia_accuracy": "97.2%",
      "last_update": "Il y a 1 heure"
    },
    {
      "id": "GM-19-SETIF",
      "wilaya": "Sétif (19)",
      "commune": "Centre Ville",
      "status": "Maintenance",
      "plastic": 0.95,
      "aluminum": 0.90,
      "ia_accuracy": "99.1%",
      "last_update": "Maintenant"
    },
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredMachines = machines.where((machine) {
      String id = machine["id"].toLowerCase();
      String wilaya = machine["wilaya"].toLowerCase();
      String commune = machine["commune"].toLowerCase();

      bool matchSearch =
          id.contains(searchText) ||
          wilaya.contains(searchText) ||
          commune.contains(searchText);

      bool matchWilaya =
          selectedWilaya == "Toutes" ||
          machine["wilaya"] == selectedWilaya;

      return matchSearch && matchWilaya;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: Text("Gestion du Parc Machines", 
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color:  Color.fromARGB(255, 46, 150, 53), size: 30),
            onPressed: () {
             _showAddMachineDialog();
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount:  filteredMachines.length,
              itemBuilder: (context, index) {
                return _buildMachineCard(filteredMachines[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddMachineDialog() {
    final TextEditingController idController = TextEditingController();
    final TextEditingController communeController = TextEditingController();

    String wilayaSelected = wilayas[1];
    String statusSelected = "En ligne";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Ajouter une machine",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            TextField(
                              controller: idController,
                              decoration: InputDecoration(
                                labelText: "ID Machine",
                                prefixIcon: const Icon(Icons.memory),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            TextField(
                              controller: communeController,
                              decoration: InputDecoration(
                                labelText: "Commune",
                                prefixIcon: const Icon(Icons.location_city),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: wilayaSelected,
                              items: wilayas.where((w) => w != "Toutes").map((wilaya) {
                                return DropdownMenuItem(
                                  value: wilaya,
                                  child: Text(wilaya),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  wilayaSelected = value!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Wilaya",
                                prefixIcon: const Icon(Icons.map),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 15),
                            DropdownButtonFormField<String>(
                              value: statusSelected,
                              items: ["En ligne", "Hors ligne", "Maintenance"].map((status) {
                                return DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setModalState(() {
                                  statusSelected = value!;
                                });
                              },
                              decoration: InputDecoration(
                                labelText: "Status",
                                prefixIcon: const Icon(Icons.settings),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.add),
                                label: const Text("Ajouter la machine"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:Color.fromARGB(255, 45, 154, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    machines.add({
                                      "id": idController.text,
                                      "wilaya": wilayaSelected,
                                      "commune": communeController.text,
                                      "status": statusSelected,
                                      "plastic": 0.0,
                                      "aluminum": 0.0,
                                      "ia_accuracy": "0%",
                                      "last_update": "Maintenant"
                                    });
                                  });
                                  Navigator.pop(context);
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchText = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: "Rechercher machine ou wilaya...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }

  Widget _buildMachineCard(Map<String, dynamic> machine) {
    bool isFull = machine['plastic'] > 0.9 || machine['aluminum'] > 0.9;
    Color statusColor = machine['status'] == "En ligne"
        ? Colors.green
        : (machine['status'] == "Hors ligne" ? Colors.red : Colors.orange);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: statusColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.precision_manufacturing, color: statusColor),
            ),
            title: Text(machine['id'], style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${machine['commune']}, ${machine['wilaya']}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(8)),
              child: Text(machine['status'], style: const TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Column(
              children: [
                _buildProgressRow("Bac Plastique", machine['plastic'], Colors.blue),
                const SizedBox(height: 12),
                _buildProgressRow("Bac Aluminium", machine['aluminum'], Colors.orange),
                const Divider(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(Icons.psychology, "IA Accuracy", machine['ia_accuracy']),
                    _buildStatItem(Icons.history, "Dernière MAJ", machine['last_update']),
                    ElevatedButton(
                      onPressed: () {
                        _showManageMachineSheet(machine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Gérer", style: TextStyle(color: Colors.white)),
                    )
                  ],
                )
              ],
            ),
          ),
          if (isFull)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
              ),
              child: const Text("Attention : Bac presque plein !", 
                textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
        ],
      ),
    );
  }

  void _showManageMachineSheet(Map<String, dynamic> machine) {
    final TextEditingController idController = TextEditingController(text: machine['id']);
    final TextEditingController communeController = TextEditingController(text: machine['commune']);
    String wilayaSelected = machine['wilaya'];
    String statusSelected = machine['status'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.8,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, spreadRadius: 5)],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Gérer Machine", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                            IconButton(icon: const Icon(Icons.close, size: 28), onPressed: () => Navigator.pop(context)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: idController,
                          decoration: InputDecoration(
                            labelText: "ID Machine",
                            prefixIcon: const Icon(Icons.memory),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 15),
                        TextField(
                          controller: communeController,
                          decoration: InputDecoration(
                            labelText: "Commune",
                            prefixIcon: const Icon(Icons.location_city),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: wilayaSelected,
                          items: wilayas.where((w) => w != "Toutes").map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                          onChanged: (v) => setModalState(() => wilayaSelected = v!),
                          decoration: InputDecoration(
                            labelText: "Wilaya",
                            prefixIcon: const Icon(Icons.map),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 15),
                        DropdownButtonFormField<String>(
                          value: statusSelected,
                          items: ["En ligne", "Hors ligne", "Maintenance"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                          onChanged: (v) => setModalState(() => statusSelected = v!),
                          decoration: InputDecoration(
                            labelText: "Status",
                            prefixIcon: const Icon(Icons.settings),
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[700],
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    machine['id'] = idController.text;
                                    machine['commune'] = communeController.text;
                                    machine['wilaya'] = wilayaSelected;
                                    machine['status'] = statusSelected;
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Sauvegarder", style: TextStyle(fontSize: 16)),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red[700],
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                ),
                                onPressed: () {
                                  setState(() {
                                    machines.remove(machine);
                                  });
                                  Navigator.pop(context);
                                },
                                child: const Text("Supprimer", style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildProgressRow(String label, double percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text("${(percent * 100).toInt()}%"),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: percent,
          backgroundColor: color.withOpacity(0.1),
          color: color,
          minHeight: 8,
          borderRadius: BorderRadius.circular(10),
        ),
      ],
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
      ],
    );
  }
}