import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/worker_model.dart';
import '../providers/settings_provider.dart';
import '../providers/worker_provider.dart';

class WorkerPage extends StatefulWidget {
  const WorkerPage({super.key});

  @override
  State<WorkerPage> createState() => _WorkerPageState();
}

class _WorkerPageState extends State<WorkerPage> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorkerProvider>().fetchWorkers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Worker> get _filtered {
    final provider = context.watch<WorkerProvider>();
    final query = _searchController.text.toLowerCase();
    return provider.workers.where((w) {
      final roleOk = _filter == 'all' ||
          (_filter == 'technicien' && w.role == WorkerRole.technicien) ||
          (_filter == 'videur' && w.role == WorkerRole.videur) ||
          (_filter == 'available' && w.status == WorkerStatus.available) ||
          (_filter == 'busy' && w.status == WorkerStatus.busy);
      final searchOk = query.isEmpty ||
          w.nomcomplet.toLowerCase().contains(query) ||
          w.city.toLowerCase().contains(query);
      return roleOk && searchOk;
    }).toList();
  }

  int get _techCount => context.read<WorkerProvider>().workers.where((w) => w.role == WorkerRole.technicien).length;
  int get _videurCount => context.read<WorkerProvider>().workers.where((w) => w.role == WorkerRole.videur).length;
  int get _pendingTasks => context.read<WorkerProvider>().workers
      .expand((w) => w.tasks)
      .where((t) => t.badgeType != TaskBadgeType.done)
      .length;

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final provider = context.watch<WorkerProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, settings),
            _buildStatsRow(context),
            _buildFilterBar(context),
            Expanded(
              child: provider.isLoading && provider.workers.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : provider.error != null && provider.workers.isEmpty
                      ? _buildErrorState(provider.error!)
                      : Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                          child: _filtered.isEmpty
                              ? _buildEmptyState()
                              : GridView.builder(
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 360,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 0.60,
                        ),
                        itemCount: _filtered.length,
                        itemBuilder: (_, i) => _WorkerCard(
                          worker: _filtered[i],
                          onAssign: () => _showAssignDialog(context, _filtered[i]),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ───────────────────────────────

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Gestion des travailleurs',
                style: GoogleFonts.outfit(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Techniciens & videurs assignés aux machines',
                style: TextStyle(color: Colors.grey[500], fontSize: 14),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddWorkerDialog(context),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Nouveau travailleur'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A18),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats ────────────────────────────────

  Widget _buildStatsRow(BuildContext context) {
    final provider = context.watch<WorkerProvider>();
    final stats = provider.dashboardStats;

    // Valeurs par défaut si les données ne sont pas encore chargées
    final totalWorkers = stats?['travailleurs']?['total'] ?? 0;
    final activeWorkers = stats?['travailleurs']?['actifs'] ?? 0;
    final totalTechs = stats?['techniciens']?['total'] ?? 0;
    final inIntervention = stats?['techniciens']?['en_intervention'] ?? 0;
    final totalVideurs = stats?['videurs']?['total'] ?? 0;
    final availableVideurs = stats?['videurs']?['disponibles'] ?? 0;
    final totalTasks = stats?['taches']?['total'] ?? 0;
    final urgentTasks = stats?['taches']?['urgentes'] ?? 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          _StatCard(
            label: 'Total travailleurs',
            value: '$totalWorkers',
            badge: '$activeWorkers actif(s) aujourd\'hui',
            badgeColor: const Color(0xFF0C447C),
            badgeBg: const Color(0xFFE6F1FB),
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Techniciens',
            value: '$totalTechs',
            badge: '$inIntervention en intervention',
            badgeColor: const Color(0xFF3C3489),
            badgeBg: const Color(0xFFEEEDFE),
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Videurs',
            value: '$totalVideurs',
            badge: '$availableVideurs disponible(s)',
            badgeColor: const Color(0xFF27500A),
            badgeBg: const Color(0xFFEAF3DE),
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Tâches en attente',
            value: '$totalTasks',
            badge: '$urgentTasks urgente(s)',
            badgeColor: const Color(0xFF633806),
            badgeBg: const Color(0xFFFAEEDA),
          ),
        ],
      ),
    );
  }

  // ── Filtres ──────────────────────────────

  Widget _buildFilterBar(BuildContext context) {
    final filters = [
      ('all', 'Tous'),
      ('technicien', 'Techniciens'),
      ('videur', 'Videurs'),
      ('available', 'Disponibles'),
      ('busy', 'En intervention'),
    ];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Wrap(
            spacing: 8,
            children: filters
                .map((f) => _FilterChip(
                      label: f.$2,
                      selected: _filter == f.$1,
                      onTap: () => setState(() => _filter = f.$1),
                    ))
                .toList(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextFormField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Rechercher un travailleur...',
                  hintStyle: const TextStyle(fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                  fillColor: Theme.of(context).cardColor,
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF10B981), width: 2),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Empty state ──────────────────────────

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            "Oups ! Une erreur s'est produite.",
            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.read<WorkerProvider>().fetchWorkers(),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text("Réessayer"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Aucun travailleur trouvé',
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ── Dialogs ──────────────────────────────

  void _showAddWorkerDialog(BuildContext context) {
    showDialog(context: context, builder: (_) => const _AddWorkerDialog());
  }

  void _showAssignDialog(BuildContext context, Worker w) {
    showDialog(context: context, builder: (_) => _AssignTaskDialog(worker: w));
  }

  void _showWorkerProfile(BuildContext context, Worker w) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorkerProfileSheet(worker: w),
    );
  }

  void _showWorkerHistory(BuildContext context, Worker w) {
    showDialog(
      context: context,
      builder: (_) => _WorkerHistoryDialog(worker: w),
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : STAT CARD
// ─────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label, value, badge;
  final Color badgeColor, badgeBg;

  const _StatCard({
    required this.label,
    required this.value,
    required this.badge,
    required this.badgeColor,
    required this.badgeBg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              blurRadius: 4,
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            const SizedBox(height: 6),
            Text(value,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(badge,
                  style: TextStyle(fontSize: 11, color: badgeColor)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : FILTER CHIP
// ─────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A1A18)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: selected
                ? const Color(0xFF1A1A18)
                : Theme.of(context).dividerColor,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: selected ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : WORKER CARD
// ─────────────────────────────────────────

class _WorkerCard extends StatelessWidget {
  final Worker worker;
  final VoidCallback onAssign;

  const _WorkerCard({required this.worker, required this.onAssign});

  Color get _avatarBg => worker.role == WorkerRole.technicien
      ? const Color(0xFFEEEDFE)
      : const Color(0xFFE1F5EE);

  Color get _avatarFg => worker.role == WorkerRole.technicien
      ? const Color(0xFF3C3489)
      : const Color(0xFF085041);

  Color get _statusColor {
    switch (worker.status) {
      case WorkerStatus.available: return const Color(0xFF639922);
      case WorkerStatus.busy:      return const Color(0xFFBA7517);
      case WorkerStatus.offline:   return const Color(0xFFE24B4A);
    }
  }

  String get _statusLabel {
    switch (worker.status) {
      case WorkerStatus.available: return 'Disponible';
      case WorkerStatus.busy:
        return worker.role == WorkerRole.videur ? 'En tournée' : 'En intervention';
      case WorkerStatus.offline: return 'Hors ligne';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            blurRadius: 4,
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(context),
          Divider(height: 24, thickness: 0.5, color: Theme.of(context).dividerColor),
          _buildInfoRow(context, 'Téléphone', worker.phone ?? 'N/A'),
          _buildInfoRow(context, 'Ville', worker.city),
          _buildInfoRow(context, 'Machines', '${worker.assignedMachines}'),
          _buildInfoRow(context, 'Tâches complétées', '${worker.tasksCompleted}'),
          if (worker.role == WorkerRole.videur && worker.fillRate != null) ...[
            const SizedBox(height: 4),
            _buildFillRate(context, worker.fillRate!),
          ],
          Divider(height: 20, thickness: 0.5, color: Theme.of(context).dividerColor),
          _buildTasksSection(context),
          const SizedBox(height: 14),
          _buildFooterButtons(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: _avatarBg,
          child: Text(
            worker.initials,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600, color: _avatarFg),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(worker.nomcomplet,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(
                worker.role == WorkerRole.videur
                    ? 'Videur de bacs'
                    : 'Technicien de maintenance',
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                      color: _statusColor, shape: BoxShape.circle),
                ),
                const SizedBox(width: 4),
                Text(_statusLabel,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _avatarBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                worker.role == WorkerRole.videur ? 'Videur' : 'Technicien',
                style: TextStyle(fontSize: 11, color: _avatarFg),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Text(label,
              style: TextStyle(fontSize: 13, color: Colors.grey[500])),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildFillRate(BuildContext context, int rate) {
    final color = rate > 80
        ? const Color(0xFFE24B4A)
        : rate > 60
            ? const Color(0xFFBA7517)
            : const Color(0xFF639922);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Taux de remplissage',
                style: TextStyle(fontSize: 13, color: Colors.grey[500])),
            const Spacer(),
            Text('$rate%',
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: rate / 100,
            minHeight: 6,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('TÂCHES ACTUELLES',
            style: TextStyle(
                fontSize: 11,
                letterSpacing: 0.5,
                color: Colors.grey[500])),
        const SizedBox(height: 8),
        ...worker.tasks.map((t) => _TaskItem(task: t)),
      ],
    );
  }

  Widget _buildFooterButtons(BuildContext context) {
    // On récupère les méthodes du State original
    final state = context.findAncestorStateOfType<_WorkerPageState>();
    
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => state?._showWorkerProfile(context, worker),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Profil',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton(
            onPressed: () => state?._showWorkerHistory(context, worker),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
              side: BorderSide(color: Theme.of(context).dividerColor),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text('Historique',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A18),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Assigner', style: TextStyle(fontSize: 12)),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : TASK ITEM
// ─────────────────────────────────────────

class _TaskItem extends StatelessWidget {
  final WorkerTask task;

  const _TaskItem({required this.task});

  Color get _dotColor {
    switch (task.badgeType) {
      case TaskBadgeType.urgent:     return const Color(0xFFE24B4A);
      case TaskBadgeType.inProgress: return const Color(0xFFBA7517);
      case TaskBadgeType.pending:    return const Color(0xFF378ADD);
      case TaskBadgeType.done:       return const Color(0xFF639922);
    }
  }

  Color get _badgeBg {
    switch (task.badgeType) {
      case TaskBadgeType.urgent:     return const Color(0xFFFCEBEB);
      case TaskBadgeType.inProgress: return const Color(0xFFFAEEDA);
      case TaskBadgeType.pending:    return const Color(0xFFE6F1FB);
      case TaskBadgeType.done:       return const Color(0xFFEAF3DE);
    }
  }

  Color get _badgeFg {
    switch (task.badgeType) {
      case TaskBadgeType.urgent:     return const Color(0xFF791F1F);
      case TaskBadgeType.inProgress: return const Color(0xFF633806);
      case TaskBadgeType.pending:    return const Color(0xFF0C447C);
      case TaskBadgeType.done:       return const Color(0xFF27500A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Theme.of(context).dividerColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: _dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task.text,
              style: const TextStyle(fontSize: 12),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: _badgeBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(task.badge,
                style: TextStyle(fontSize: 11, color: _badgeFg)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DIALOG : AJOUTER UN TRAVAILLEUR
// ─────────────────────────────────────────

class _AddWorkerDialog extends StatefulWidget {
  const _AddWorkerDialog();

  @override
  State<_AddWorkerDialog> createState() => _AddWorkerDialogState();
}

class _AddWorkerDialogState extends State<_AddWorkerDialog> {
  final _formKey = GlobalKey<FormState>();
  WorkerRole _selectedRole = WorkerRole.technicien;
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _cityCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WorkerProvider>();

    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text('Nouveau travailleur',
          style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w600)),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogField(
                label: 'Nom complet', 
                controller: _nameCtrl,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Le nom est requis';
                  if (RegExp(r'[0-9]').hasMatch(v)) return 'Le nom ne peut pas contenir de chiffres';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _DialogField(
                label: 'Téléphone', 
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Le téléphone est requis';
                  if (!RegExp(r'^[0-9+ ]+$').hasMatch(v)) return 'Format invalide (chiffres uniquement)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _DialogField(
                label: 'Ville', 
                controller: _cityCtrl,
                validator: (v) => v == null || v.isEmpty ? 'La ville est requise' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Text('Rôle',
                      style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                  const Spacer(),
                  _RoleToggle(
                    selected: _selectedRole,
                    onChanged: (r) => setState(() => _selectedRole = r),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler',
              style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            
            final success = await provider.addWorker({
              "username": _nameCtrl.text.toLowerCase().replaceAll(' ', '.'),
              "nomcomplet": _nameCtrl.text,
              "email": "${_nameCtrl.text.toLowerCase().replaceAll(' ', '.')}@recycle.dz", // Dummy email
              "password": "Password123", // Default password
              "phone": _phoneCtrl.text,
              "city": _cityCtrl.text,
              "role": _selectedRole.name,
              "adress": "Non renseigné",
            });

            if (mounted) {
              if (success) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Travailleur ajouté avec succès')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur : ${provider.error ?? "Inconnue"}')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A18),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: provider.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Ajouter', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : DIALOG FIELD
// ─────────────────────────────────────────

class _DialogField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const _DialogField({
    required this.label, 
    required this.controller,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        filled: true,
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Theme.of(context).dividerColor, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: Color(0xFF10B981), width: 2),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  WIDGET : ROLE TOGGLE
// ─────────────────────────────────────────

class _RoleToggle extends StatelessWidget {
  final WorkerRole selected;
  final ValueChanged<WorkerRole> onChanged;

  const _RoleToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoleBtn(
          label: 'Technicien',
          active: selected == WorkerRole.technicien,
          onTap: () => onChanged(WorkerRole.technicien),
        ),
        const SizedBox(width: 6),
        _RoleBtn(
          label: 'Videur',
          active: selected == WorkerRole.videur,
          onTap: () => onChanged(WorkerRole.videur),
        ),
      ],
    );
  }
}

class _RoleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _RoleBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A1A18) : Theme.of(context).cardColor,
          border: Border.all(
            color: active
                ? const Color(0xFF1A1A18)
                : Theme.of(context).dividerColor,
            width: 0.8,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: active ? Colors.white : Colors.grey[600])),
      ),
    );
  }
}

// ─────────────────────────────────────────
//  DIALOG : ASSIGNER UNE TÂCHE
// ─────────────────────────────────────────

class _AssignTaskDialog extends StatefulWidget {
  final Worker worker;

  const _AssignTaskDialog({required this.worker});

  @override
  State<_AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<_AssignTaskDialog> {
  final List<String> _machines = ['M-001', 'M-002', 'M-003', 'M-004', 'M-005'];
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        'Assigner à ${widget.worker.nomcomplet}',
        style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w600),
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: _machines
              .map((m) => _MachineSelectRow(
                    machine: m,
                    isVideur: widget.worker.role == WorkerRole.videur,
                    selected: _selected.contains(m),
                    onToggle: () => setState(() {
                      _selected.contains(m)
                          ? _selected.remove(m)
                          : _selected.add(m);
                    }),
                  ))
              .toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Annuler',
              style: TextStyle(color: Colors.grey[600])),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${_selected.length} machine(s) assignée(s) à ${widget.worker.nomcomplet}'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1A1A18),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Confirmer', style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────
//  NEW WIDGET : WORKER PROFILE SHEET
// ─────────────────────────────────────────

class _WorkerProfileSheet extends StatelessWidget {
  final Worker worker;
  const _WorkerProfileSheet({required this.worker});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.green.withOpacity(0.1),
                child: Text(worker.initials, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.green)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(worker.nomcomplet, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(worker.role.name.toUpperCase(), style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ],
                ),
              ),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 24),
          _ProfileInfoItem(icon: Icons.email_outlined, label: 'Email', value: worker.email),
          _ProfileInfoItem(icon: Icons.phone_outlined, label: 'Téléphone', value: worker.phone ?? 'N/A'),
          _ProfileInfoItem(icon: Icons.location_city_outlined, label: 'Ville', value: worker.city),
          _ProfileInfoItem(icon: Icons.location_on_outlined, label: 'Adresse', value: worker.adress),
          _ProfileInfoItem(icon: Icons.calendar_today_outlined, label: 'Membre depuis', value: '${worker.createdAt.day}/${worker.createdAt.month}/${worker.createdAt.year}'),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _ProfileInfoItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.green),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
//  NEW WIDGET : WORKER HISTORY DIALOG
// ─────────────────────────────────────────

class _WorkerHistoryDialog extends StatelessWidget {
  final Worker worker;
  const _WorkerHistoryDialog({required this.worker});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Historique — ${worker.nomcomplet}', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
      content: SizedBox(
        width: 400,
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_rounded, size: 60, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text('Aucune activité récente', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'Les tâches terminées et les interventions passées apparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Fermer')),
      ],
    );
  }
}

class _MachineSelectRow extends StatelessWidget {
  final String machine;
  final bool isVideur;
  final bool selected;
  final VoidCallback onToggle;

  const _MachineSelectRow({
    required this.machine,
    required this.isVideur,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF1A1A18).withOpacity(0.04)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected
                ? const Color(0xFF1A1A18)
                : Theme.of(context).dividerColor,
            width: selected ? 1 : 0.8,
          ),
        ),
        child: Row(
          children: [
            Text(machine,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 10),
            Text(
              isVideur ? 'Vider les bacs' : 'Vérifier la panne',
              style: TextStyle(fontSize: 12, color: Colors.grey[500]),
            ),
            const Spacer(),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF1A1A18)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? const Color(0xFF1A1A18)
                      : Theme.of(context).dividerColor,
                  width: 0.8,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 13, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}