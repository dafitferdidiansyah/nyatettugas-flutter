// Lokasi: lib/features/settings/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _taskNotifEnabled = true;
  bool _courseNotifEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _taskNotifEnabled = prefs.getBool('task_notif') ?? true;
      _courseNotifEnabled = prefs.getBool('course_notif') ?? true;
    });
  }

  _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value);
  }

  _toggleSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
          
          const SizedBox(height: 30),
          _buildSectionHeader("Reminders & Alerts"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text("Task Deadlines", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Alerts before tasks are due", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  activeColor: const Color(0xFF00E676),
                  value: _taskNotifEnabled,
                  onChanged: (val) {
                    setState(() => _taskNotifEnabled = val);
                    _toggleSetting('task_notif', val);
                  },
                ),
                Divider(color: Colors.grey.shade800, height: 1),
                SwitchListTile(
                  title: const Text("Course Schedules", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Alerts before classes start", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  activeColor: const Color(0xFF00E676),
                  value: _courseNotifEnabled,
                  onChanged: (val) {
                    setState(() => _courseNotifEnabled = val);
                    _toggleSetting('course_notif', val);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
          _buildSectionHeader("Data Management"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.download, color: Colors.white),
                  title: const Text("Export Backup", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Save tasks to device storage", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () => _showSnackbar("Export feature triggered"),
                ),
                Divider(color: Colors.grey.shade800, height: 1),
                ListTile(
                  leading: const Icon(Icons.upload, color: Colors.white),
                  title: const Text("Import Backup", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Restore tasks from a file", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  onTap: () => _showSnackbar("Import feature triggered"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
    );
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.grey.shade800));
  }
}