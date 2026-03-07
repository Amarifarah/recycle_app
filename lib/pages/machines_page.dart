import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MachinesPage extends StatefulWidget {
  const MachinesPage({super.key});

  @override
  State<MachinesPage> createState() => _MachinesPageState();
}

class _MachinesPageState extends State<MachinesPage> {
  final Color darkGreen = const Color(0xFF1E591E);
  
  List<Map<String, dynamic>> machines = [];
  String searchQuery = "";

  // Variables d'erreurs
  String? idError, nameError, typeError, wilayaError, capacityError;

  final List<String> wilayas = [
    "Adrar", "Chlef", "Laghouat", "Oum El Bouaghi", "Batna", "Béjaïa", "Biskra", "Béchar", "Blida", "Bouira", "Tamanrasset", "Tébessa", "Tlemcen", "Tiaret", "Tizi Ouzou", "Alger", "Djelfa", "Jijel", "Sétif", "Saïda", "Skikda", "Sidi Bel Abbès", "Annaba", "Guelma", "Constantine", "Médéa", "Mostaganem", "M'Sila", "Mascara", "Ouargla", "Oran", "El Bayadh", "Illizi", "Bordj Bou Arreridj", "Boumerdès", "El Tarf", "Tindouf", "Tissemsilt", "El Oued", "Khenchela", "Souk Ahras", "Tipaza", "Mila", "Aïn Defla", "Naâma", "Aïn Témouchent", "Ghardaïa", "Relizane", "Timimoun", "Bordj Badji Mokhtar", "Ouled Djellal", "Béni Abbès", "In Salah", "In Guezzam", "Touggourt", "Djanet", "El M'Ghair", "El Meniaa"
  ];

  final List<String> typeOptions = ["Aluminium", "Verre", "Carton", "Plastique"];
  List<String> selectedTypes = [];
  String? machineWilaya;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController idController = TextEditingController();
  final TextEditingController capacityController = TextEditingController();

  // --- DIALOGUE DE CONFIRMATION PERSONNALISÉ ---
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 15),
                Text("Supprimer la machine ?", style: GoogleFonts.lato(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(
                  "Voulez-vous vraiment supprimer ${machines[index]['name']} ? Cette action est irréversible.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: () {
                          setState(() => machines.removeAt(index));
                          Navigator.pop(context);
                        },
                        child: const Text("Supprimer", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSave(StateSetter setModalState) {
    setModalState(() {
      idError = (idController.text.isEmpty || int.tryParse(idController.text) == null) ? "ID numérique requis" : null;
      nameError = nameController.text.trim().isEmpty ? "Nom obligatoire" : null;
      capacityError = (capacityController.text.isEmpty || double.tryParse(capacityController.text) == null) ? "Capacité requise" : null;
      wilayaError = (machineWilaya == null) ? "Choisissez une Wilaya" : null;
      typeError = selectedTypes.isEmpty ? "Cochez au moins un type" : null;
    });

    if (idError == null && nameError == null && capacityError == null && wilayaError == null && typeError == null) {
      setState(() {
        machines.add({
          "id": idController.text,
          "name": nameController.text,
          "wilaya": machineWilaya,
          "capacity": capacityController.text,
          "types": List.from(selectedTypes),
        });
      });
      _clearInputs();
      Navigator.pop(context);
    }
  }

  void _clearInputs() {
    idController.clear(); nameController.clear(); capacityController.clear();
    selectedTypes.clear(); machineWilaya = null;
  }

  void _showAddMachineSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
                const SizedBox(height: 20),
                Text("Configuration Machine", style: GoogleFonts.lato(fontSize: 20, fontWeight: FontWeight.bold, color: darkGreen)),
                const SizedBox(height: 20),
                _buildField(idController, "ID Machine", Icons.fingerprint, idError, isNum: true),
                _buildField(nameController, "Nom", Icons.settings, nameError),
                Autocomplete<String>(
                  optionsBuilder: (val) => wilayas.where((w) => w.toLowerCase().contains(val.text.toLowerCase())),
                  onSelected: (s) => setModalState(() => machineWilaya = s),
                  fieldViewBuilder: (ctx, ctrl, node, onSub) => TextField(
                    controller: ctrl, focusNode: node,
                    decoration: InputDecoration(
                      labelText: "Wilaya", prefixIcon: const Icon(Icons.map),
                      errorText: wilayaError, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                _buildField(capacityController, "Capacité Max (kg)", Icons.bar_chart, capacityError, isNum: true),
                const Text("Bacs disponibles :", style: TextStyle(fontWeight: FontWeight.bold)),
                Wrap(
                  spacing: 8,
                  children: typeOptions.map((type) => FilterChip(
                    label: Text(type),
                    selected: selectedTypes.contains(type),
                    onSelected: (val) => setModalState(() => val ? selectedTypes.add(type) : selectedTypes.remove(type)),
                  )).toList(),
                ),
                if (typeError != null) Text(typeError!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity, height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: darkGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                    onPressed: () => _handleSave(setModalState),
                    child: const Text("ENREGISTRER", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, IconData icon, String? err, {bool isNum = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: ctrl,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label, prefixIcon: Icon(icon),
          errorText: err, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = machines.where((m) => m['wilaya'].toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      appBar: AppBar(title: Text("Parc Machines", style: GoogleFonts.lato(fontWeight: FontWeight.bold)), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                hintText: "Rechercher une Wilaya...", prefixIcon: const Icon(Icons.search),
                filled: true, fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 15),
            ElevatedButton.icon(
              onPressed: _showAddMachineSheet,
              icon: const Icon(Icons.add_circle_outline, color: Colors.white),
              label: const Text("AJOUTER UNE MACHINE", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(backgroundColor: darkGreen, minimumSize: const Size(double.infinity, 50)),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: filtered.length,
                itemBuilder: (ctx, i) {
                  final m = filtered[i];
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: CircleAvatar(backgroundColor: darkGreen.withOpacity(0.1), child: Icon(Icons.precision_manufacturing, color: darkGreen)),
                      title: Text("${m['name']} (ID: ${m['id']})", style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text("📍 ${m['wilaya']}\n📊 ${m['capacity']} kg | ${m['types'].join(', ')}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.settings_outlined, color: Colors.blueGrey),
                            onPressed: () { /* Future action Modifier */},
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            onPressed: () => _showDeleteDialog(i), // Appel au nouveau dialogue
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