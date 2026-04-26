import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  int _taskReminderValue = 60;
  int _courseReminderValue = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _nameController.text = prefs.getString('user_name') ?? '';
      _taskReminderValue = prefs.getInt('task_reminder_val') ?? 60;
      _courseReminderValue = prefs.getInt('course_reminder_val') ?? 15;
    });
  }

  _saveName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', value);
  }

  // ── Helper: konversi menit → label yang manusiawi ──────────────────────────
  // Dipanggil di subtitle setting DAN di daftar pilihan bawah
  String _formatReminderLabel(int minutes) {
    if (minutes >= 1440 && minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      return days == 1 ? '1 Day' : '$days Days';
    } else if (minutes >= 60 && minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return hours == 1 ? '1 Hour' : '$hours Hours';
    } else {
      return '$minutes Minutes';
    }
  }

  void _exportDatabase() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final files = dbFolder.listSync();
      File? dbFile;
      for (var entity in files) {
        if (entity is File && entity.path.endsWith('.sqlite')) {
          dbFile = entity;
          break;
        }
      }
      if (dbFile != null && await dbFile.exists()) {
        await Share.shareXFiles([XFile(dbFile.path)],
            text: 'Backup Database NyatetTugas');
      } else {
        _showSnackbar("Error: File database .sqlite tidak ditemukan!",
            isError: true);
      }
    } catch (e) {
      _showSnackbar("Export failed: $e", isError: true);
    }
  }

  void _importDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.pickFiles();
      if (result != null && result.files.single.path != null) {
        final importedFile = File(result.files.single.path!);
        if (!importedFile.path.endsWith('.sqlite')) {
          _showSnackbar("Gagal! Pilih file backup yang berakhiran .sqlite",
              isError: true);
          return;
        }
        final dbFolder = await getApplicationDocumentsDirectory();
        final files = dbFolder.listSync();
        File? originalDb;
        for (var entity in files) {
          if (entity is File && entity.path.endsWith('.sqlite')) {
            originalDb = entity;
            break;
          }
        }
        if (originalDb != null) {
          await importedFile.copy(originalDb.path);
          _showSnackbar("Import Sukses! Silakan restart aplikasi.",
              isSuccess: true);
        } else {
          _showSnackbar("Gagal: Database sistem belum terbuat.", isError: true);
        }
      }
    } catch (e) {
      _showSnackbar("Import failed: $e", isError: true);
    }
  }

  void _showReminderPicker(String title, bool isTask) {
    // Daftar opsi: [nilai menit, label tampilan]
    final options = <(int, String)>[
      (15, '15 Minutes before'),
      (30, '30 Minutes before'),
      (60, '1 Hour before'),
      (1440, '1 Day before'),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        // StatefulBuilder agar centang di dalam sheet ikut update
        builder: (context, setSheetState) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
            const Divider(color: Colors.white10, height: 1),
            ...options.map(
              (opt) => _buildOption(
                opt.$1,
                opt.$2,
                isTask,
                setSheetState,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(
    int val,
    String label,
    bool isTask,
    StateSetter setSheetState,
  ) {
    final isSelected =
        isTask ? _taskReminderValue == val : _courseReminderValue == val;

    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: isSelected
          ? const Icon(Icons.check, color: Color(0xFF00E676), size: 18)
          : null,
      onTap: () async {
        final prefs = await SharedPreferences.getInstance();
        if (isTask) {
          await prefs.setInt('task_reminder_val', val);
          // Update keduanya: state lokal sheet & state halaman
          setSheetState(() => _taskReminderValue = val);
          setState(() => _taskReminderValue = val);
        } else {
          await prefs.setInt('course_reminder_val', val);
          setSheetState(() => _courseReminderValue = val);
          setState(() => _courseReminderValue = val);
        }
        if (mounted) Navigator.pop(context);
      },
    );
  }

  void _showSnackbar(String msg,
      {bool isError = false, bool isSuccess = false}) {
    Color bgColor = const Color(0xFF1E1E1E);
    Color textColor = Colors.white;
    if (isError) bgColor = Colors.redAccent;
    if (isSuccess) {
      bgColor = const Color(0xFF00E676);
      textColor = Colors.black;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
      backgroundColor: bgColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Settings',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        children: [
          _buildSectionHeader("PERSONALIZATION"),
          _buildCard(
            child: TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.white),
              onChanged: _saveName,
              cursorColor: const Color(0xFF00E676),
              decoration: const InputDecoration(
                labelText: "Preferred Name",
                labelStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon:
                    Icon(Icons.person_outline, color: Color(0xFF00E676)),
                contentPadding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),

          const SizedBox(height: 28),
          _buildSectionHeader("GLOBAL REMINDERS"),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.task_alt, color: Color(0xFF00E676)),
                  title: const Text("Task Deadlines",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  // ✅ Gunakan _formatReminderLabel agar tampil "1 Hour", "1 Day", dll.
                  subtitle: Text(
                    "Notify ${_formatReminderLabel(_taskReminderValue)} before",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () => _showReminderPicker("Task Reminder", true),
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.school_outlined,
                      color: Color(0xFF00E676)),
                  title: const Text("Course Schedule",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  // ✅ Sama untuk course reminder
                  subtitle: Text(
                    "Notify ${_formatReminderLabel(_courseReminderValue)} before",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: () => _showReminderPicker("Course Reminder", false),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          _buildSectionHeader("DATA MANAGEMENT"),
          _buildCard(
            child: Column(
              children: [
                ListTile(
                  leading:
                      const Icon(Icons.save_alt, color: Color(0xFF00E676)),
                  title: const Text("Export Backup",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Share .sqlite to Drive/Docs",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: _exportDatabase,
                ),
                const Divider(color: Colors.white10, height: 1, indent: 56),
                ListTile(
                  leading:
                      const Icon(Icons.restore, color: Colors.orangeAccent),
                  title: const Text("Import Backup",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  subtitle: const Text("Restore from .sqlite file",
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                  onTap: _importDatabase,
                ),
              ],
            ),
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text("v1.0.0",
                style: TextStyle(
                    color: Colors.white24,
                    fontSize: 12,
                    letterSpacing: 2)),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(title,
          style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }
}