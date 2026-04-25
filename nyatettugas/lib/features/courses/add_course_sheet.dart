import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column; // Sembunyikan Column milik drift agar tidak bentrok dengan widget Column Flutter
import '../../core/database/app_database.dart'; // Import struktur database

class AddCourseSheet extends StatefulWidget {
  const AddCourseSheet({super.key});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  final TextEditingController _lecturerController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  // Murni logika Vibe Coder untuk simpan data
  void _saveCourse() async {
    final name = _nameController.text;
    final day = _dayController.text;
    final time = _timeController.text;
    
    // 1. Validasi Super Simpel
    if (name.isEmpty || day.isEmpty || time.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name, Day, and Time are required!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    // 2. Ambil "Kunci" Database dari Main.dart
    final db = context.read<AppDatabase>();

    // 3. Masukkan Data ke Tabel Courses (SQL Insert ala Drift)
    try {
      await db.into(db.courses).insert(
        CoursesCompanion.insert(
          name: name,
          day: day,
          time: time,
          room: Value(_roomController.text), // Value() digunakan karena field ini opsional (nullable) di database
          lecturer: Value(_lecturerController.text),
          colorValue: const Value(0xFF2196F3), // Default warna biru, nanti bisa di-custom
        ),
      );

      // Jika berhasil, pamerkan notifikasi hijau
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Course "$name" saved permanently!'), backgroundColor: const Color(0xFF00E676)),
      );
      Navigator.pop(context); // Tutup Form

    } catch (e) {
      // Jika ada error (misal memori penuh, dll)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: Colors.grey.shade400),
          hintStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: icon != null ? Icon(icon, color: const Color(0xFF00E676)) : null,
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00E676), width: 1.5),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4, margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const Text('Add New Course', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            _buildTextField('Course Name', 'e.g. Mobile Programming', _nameController, icon: Icons.book_outlined),
            Row(
              children: [
                Expanded(child: _buildTextField('Day', 'e.g. Monday', _dayController, icon: Icons.calendar_today)),
                const SizedBox(width: 16),
                Expanded(child: _buildTextField('Time', 'e.g. 08:00', _timeController, icon: Icons.access_time)),
              ],
            ),
            _buildTextField('Room / Location', 'e.g. Lab ICT 2nd Floor', _roomController, icon: Icons.room_outlined),
            _buildTextField('Lecturer', 'e.g. Mr. John Doe', _lecturerController, icon: Icons.person_outline),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity, height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E676),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _saveCourse, // PANGGIL FUNGSI SIMPAN DI SINI
                child: const Text('Save Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}