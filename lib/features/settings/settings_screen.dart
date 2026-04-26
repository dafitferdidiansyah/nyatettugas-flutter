import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _notificationsEnabled = prefs.getBool('notif_enabled') ?? true;
    });
  }

  _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value);
  }

  _toggleNotif(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_enabled', value);
    setState(() => _notificationsEnabled = value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        children: [
          _buildSectionHeader("Personalization"),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.white),
            onChanged: _saveName,
            decoration: InputDecoration(
              labelText: "Preferred Name",
              labelStyle: const TextStyle(color: Colors.grey),
              filled: true,
              fillColor: const Color(0xFF1E1E1E),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF00E676)),
            ),
          ),
          
          const SizedBox(height: 24),
          _buildSectionHeader("Reminders"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: SwitchListTile(
              title: const Text("Allow Notifications", style: TextStyle(color: Colors.white)),
              subtitle: const Text("Daily briefings and deadlines", style: TextStyle(color: Colors.grey, fontSize: 12)),
              activeColor: const Color(0xFF00E676),
              value: _notificationsEnabled,
              onChanged: _toggleNotif,
              secondary: const Icon(Icons.notifications_active_outlined, color: Color(0xFF00E676)),
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("Data Management"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: const Text("Export Backup", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Save tasks to device storage", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () {
                    // TODO: Logic Export SQLite
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Export feature coming soon!')));
                  },
                ),
                Divider(color: Colors.grey.shade800, height: 1),
                ListTile(
                  leading: const Icon(Icons.upload, color: Colors.white),
                  title: const Text("Import Backup", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Restore tasks from a file", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () {
                    // TODO: Logic Import SQLite
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Import feature coming soon!')));
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          _buildSectionHeader("Danger Zone"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cleaning_services, color: Colors.redAccent),
                  title: const Text("Clear Completed Tasks", style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    // TODO: Query delete isCompleted == true
                  },
                ),
                Divider(color: Colors.grey.shade800, height: 1),
                ListTile(
                  leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                  title: const Text("Erase All Data", style: TextStyle(color: Colors.redAccent)),
                  onTap: () {
                    // TODO: Drop tables
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.2)),
    );
  }
}