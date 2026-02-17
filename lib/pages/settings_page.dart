import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/settings_model.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Settings settings;

  @override
  void initState() {
    super.initState();
    settings = Settings.defaultSettings();
    _loadSettings();
  }

  // --- Charger les préférences depuis SharedPreferences ---
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString('settings');
    if (settingsJson != null) {
      setState(() {
        settings = Settings.fromMap(jsonDecode(settingsJson));
      });
    }
  }

  // --- Sauvegarder les préférences dans SharedPreferences ---
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('settings', jsonEncode(settings.toMap()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Paramètres',
          style: GoogleFonts.outfit(
            color: const Color(0xFF1F2937),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: const Color(0xFFE5E7EB), height: 1.0),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Profil utilisateur'),
              _buildProfileCard(),
              const SizedBox(height: 24),

              _buildSectionTitle('Notifications'),
              _buildSettingsGroup([
                _buildSwitchTile(
                  'Notifications Push',
                  'Recevoir des alertes sur votre mobile',
                  settings.pushNotifications,
                  (val) {
                    setState(() => settings.pushNotifications = val);
                    _saveSettings();
                  },
                  Icons.notifications_active_outlined,
                ),
                _buildSwitchTile(
                  'Notifications Email',
                  'Recevoir les rapports par mail',
                  settings.emailNotifications,
                  (val) {
                    setState(() => settings.emailNotifications = val);
                    _saveSettings();
                  },
                  Icons.email_outlined,
                ),
              ]),
              const SizedBox(height: 24),

              _buildSectionTitle('Préférences système'),
              _buildSettingsGroup([
                _buildDropdownTile(
                  'Langue de l\'interface',
                  settings.language,
                  ['Français (FR)', 'English (EN)', 'Español (ES)'],
                  (val) {
                    setState(() => settings.language = val!);
                    _saveSettings();
                  },
                  Icons.language,
                ),
                _buildDropdownTile(
                  'Unité de mesure',
                  settings.unit,
                  ['Kilogrammes (kg)', 'Livres (lb)'],
                  (val) {
                    setState(() => settings.unit = val!);
                    _saveSettings();
                  },
                  Icons.straighten,
                ),
                _buildSwitchTile(
                  'Mode Sombre',
                  'Activer l\'interface sombre',
                  settings.darkMode,
                  (val) {
                    setState(() => settings.darkMode = val);
                    _saveSettings();
                  },
                  Icons.dark_mode_outlined,
                ),
              ]),
              const SizedBox(height: 24),

              _buildSectionTitle('Sécurité'),
              _buildSettingsGroup([
                _buildActionTile(
                  'Changer le mot de passe',
                  Icons.lock_outline,
                  onTap: () {},
                ),
                _buildActionTile(
                  'Double authentification (2FA)',
                  Icons.security,
                  onTap: () {},
                ),
              ]),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text(
                    'Déconnexion',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI reusable widgets ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF6B7280),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage(
              'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alexandre Martin',
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'admin.alexandre@recyclage.io',
                  style: TextStyle(color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Modifier'),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF10B981)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Switch.adaptive(
        value: value,
        activeColor: const Color(0xFF10B981),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String value,
    List<String> items,
    Function(String?) onChanged,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF3B82F6)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((String val) {
          return DropdownMenuItem<String>(value: val, child: Text(val));
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    IconData icon, {
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right, size: 20),
    );
  }
}
