import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:recycle_app/pages/machines_page.dart';
import '../models/dashboard_model.dart';
import '../widgets/sidebar.dart';
import '../pages/clients_page.dart';
import 'settings_page.dart';
import 'analytics_page.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../models/login_model.dart';
import '../providers/settings_provider.dart';
import '../providers/machine_provider.dart';
import '../providers/notification_provider.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  String selectedPage = "dashboard";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          SideBar(
            selectedPage: selectedPage,
            onItemSelected: (page) async {
              if (page == 'logout') {
                // Déconnexion complète
                await Provider.of<LoginModel>(context, listen: false).logout();
                if (mounted) {
                  // Retour vers la page de login
                  Navigator.pushReplacementNamed(context, "/login");
                }
              } else {
                setState(() {
                  selectedPage = page;
                });
              }
            },
          ),
          // Contenu
          Expanded(child: getPage()),
        ],
      ),
    );
  }

  Widget getPage() {
    switch (selectedPage) {
      case "dashboard":
        return DashboardHome(key: UniqueKey()); // Force refresh when switching tabs

      case "clients":
        return ClientsPage();

      case "machines":
        return const MachinesPage();

      case "analytics":
        return AnalyticsPage();

      case "settings":
        return SettingsPage();

      case "logout":
        return const Center(child: Text("Logout"));

      default:
        return const Center(child: Text("Page not found"));
    }
  }
}

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  @override
  void initState() {
    super.initState();
    // Appeler le fetch au chargement
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashboardPageModel>(context, listen: false).fetchStats();
      Provider.of<MachineProvider>(context, listen: false).fetchMachines();
      Provider.of<NotificationProvider>(context, listen: false).fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    return Column(
      children: [
        _buildHeader(context, settings),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildStatsRow(context, settings),
                const SizedBox(height: 20),
                _buildMapSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // 🔔 HEADER
  Widget _buildHeader(BuildContext context, SettingsProvider settings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            settings.translate('dashboard'),
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),

          // 🔔 Notification button
          Consumer<NotificationProvider>(
            builder: (context, notifProvider, child) {
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () {
                      _showNotifications(context, settings);
                    },
                  ),
                  if (notifProvider.unreadCount > 0)
                    Positioned(
                      right: 4,
                      top: 4,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${notifProvider.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return "N/A";
    try {
      DateTime dt = DateTime.parse(dateStr.toString());
      return DateFormat('dd/MM/yyyy HH:mm').format(dt);
    } catch (_) {
      return dateStr.toString();
    }
  }

  // 🔔 POPUP NOTIFICATIONS (DYNAMIQUE)
  void _showNotifications(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer<NotificationProvider>(
          builder: (context, provider, child) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                   const Text("Notifications"),
                   Row(
                     children: [
                       if (provider.isLoading)
                        const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                       IconButton(
                         icon: const Icon(Icons.refresh, size: 20),
                         onPressed: () => provider.fetchNotifications(),
                       ),
                     ],
                   ),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 450,
                child: provider.notifications.isEmpty
                  ? Center(child: Text("Aucune notification", style: GoogleFonts.poppins(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: provider.notifications.length,
                      separatorBuilder: (context, index) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notif = provider.notifications[index];
                        final String id = notif['_id'].toString();
                        final String type = (notif['type'] ?? 'info').toString();
                        final String message = notif['message'] ?? '...';
                        final String status = notif['status'] ?? 'envoyée';
                        final bool isRead = status == 'lue';
                        
                        // Icône selon le type
                        IconData leadingIcon = Icons.notifications;
                        Color iconColor = Colors.blue;
                        if (type.contains('panne')) {
                          leadingIcon = Icons.error_outline;
                          iconColor = Colors.red;
                        } else if (type.contains('remplissage')) {
                          leadingIcon = Icons.battery_charging_full;
                          iconColor = Colors.orange;
                        }

                        return Opacity(
                          opacity: isRead ? 0.6 : 1.0,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                            leading: CircleAvatar(
                              backgroundColor: iconColor.withOpacity(0.1),
                              child: Icon(leadingIcon, color: isRead ? Colors.grey : iconColor, size: 20),
                            ),
                            title: Row(
                              children: [
                                Text(type.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                                if (isRead) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                    child: const Text("TRAITÉ", style: TextStyle(color: Colors.green, fontSize: 9, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(message, style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color, fontSize: 13, fontWeight: isRead ? FontWeight.normal : FontWeight.w500)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 10, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("Alert: ${_formatDate(notif['created_at'])}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                if (isRead && notif['updated_at'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 2),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.check_circle, size: 10, color: Colors.green),
                                        const SizedBox(width: 4),
                                        Text("Traité: ${_formatDate(notif['updated_at'])}", style: const TextStyle(fontSize: 10, color: Colors.green)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            trailing: isRead 
                              ? const Icon(Icons.done_all, color: Colors.green, size: 20)
                              : Tooltip(
                                  message: "Marquer comme traité",
                                  child: IconButton(
                                    icon: const Icon(Icons.check_circle_outline, color: Colors.green),
                                    onPressed: () => provider.markAsRead(id),
                                  ),
                                ),
                          ),
                        );
                      },
                    ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Fermer"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildStatsRow(BuildContext context, SettingsProvider settings) {
    final model = Provider.of<DashboardPageModel>(context);

    if (model.isLoading && model.totalMachines == 0) {
      return const Center(child: CircularProgressIndicator());
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _smallCard(
          context,
          "${model.totalAluminum.toStringAsFixed(1)}",
          settings.translate('aluminum') + " (kg)",
          Icons.recycling,
        ),
        _smallCard(
          context,
          "${model.totalPlastic.toStringAsFixed(1)}",
          settings.translate('plastic') + " (kg)",
          Icons.recycling,
        ),
        _smallCard(context, "${model.totalMachines}", settings.translate('machines'), Icons.point_of_sale),
      ],
    );
  }

  Widget _smallCard(BuildContext context, String value, String label, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: Colors.green),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 10, overflow: TextOverflow.ellipsis)),
          ],
        ),
      ),
    );
  }

  // 🗺️ MAP FIX

  Widget _buildMapSection() {
    return SizedBox(
      height: 545,
      child: Consumer<MachineProvider>(
        builder: (context, provider, child) {
          final machines = provider.machines;
          
          return FlutterMap(
            options: MapOptions(
              initialCenter: machines.isNotEmpty 
                  ? LatLng(
                      double.tryParse(machines[0]['latitude']?.toString() ?? '28.0339') ?? 28.0339, 
                      double.tryParse(machines[0]['longitude']?.toString() ?? '1.6596') ?? 1.6596
                    )
                  : LatLng(28.0339, 1.6596), // Algérie par défaut
              initialZoom: machines.isNotEmpty ? 6 : 5,
            ),
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.recycleapp',
              ),
              // 📍 MARKERS DYNAMIQUES
              MarkerLayer(
                markers: machines.map((m) {
                  final double lat = double.tryParse(m['latitude']?.toString() ?? '0') ?? 0;
                  final double lon = double.tryParse(m['longitude']?.toString() ?? '0') ?? 0;
                  final String rawStatus = (m['status'] ?? 'actif').toString().toLowerCase().trim();
                  
                  // Déterminer la couleur selon le statut (Plus robuste)
                  Color markerColor = Colors.green; // Par défaut Online (actif)
                  if (rawStatus.contains('panne') || rawStatus.contains('maintenance')) {
                    markerColor = Colors.red;
                  } else if (rawStatus.contains('hors ligne') || rawStatus.contains('offline') || rawStatus.contains('inactif')) {
                    markerColor = Colors.orange;
                  }

                  return Marker(
                    point: LatLng(lat, lon),
                    width: 40,
                    height: 40,
                    child: Icon(Icons.location_on, color: markerColor, size: 30),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
