import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
    });
  }

  Future<void> _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value);
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
          _buildSectionHeader("Global Reminder Settings"),
          Container(
            decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  title: const Text("Task Deadlines", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Notify 1 hour before due date", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                  onTap: () {
                    _showSnackbar("Task reminder settings coming soon!");
                  },
                ),
                Divider(color: Colors.grey.shade800, height: 1),
                ListTile(
                  title: const Text("Course Schedule", style: TextStyle(color: Colors.white)),
                  subtitle: const Text("Notify 15 minutes before class", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white24),
                  onTap: () {
                    _showSnackbar("Course reminder settings coming soon!");
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