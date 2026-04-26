import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';

class AddCourseSheet extends StatefulWidget {
  final Course? courseToEdit;
  const AddCourseSheet({super.key, this.courseToEdit});

  @override
  State<AddCourseSheet> createState() => _AddCourseSheetState();
}

class _AddCourseSheetState extends State<AddCourseSheet> {
  final _nameController = TextEditingController();
  final _dayController = TextEditingController();
  final _timeController = TextEditingController();
  final _roomController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _nameController.text = widget.courseToEdit!.name;
      _dayController.text = widget.courseToEdit!.day;
      _timeController.text = widget.courseToEdit!.time ?? '';
      _roomController.text = widget.courseToEdit!.room ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _saveCourse() async {
    if (_nameController.text.isEmpty || _dayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name and Day are required!'), backgroundColor: Colors.redAccent));
      return;
    }
    
    final db = context.read<AppDatabase>();
    try {
      if (widget.courseToEdit == null) {
        // [PERBAIKAN 1]: Gunakan CoursesCompanion (tanpa .insert) agar semua dibungkus Value()
        await db.into(db.courses).insert(CoursesCompanion(
          name: Value(_nameController.text),
          day: Value(_dayController.text),
          time: Value(_timeController.text),
          room: Value(_roomController.text),
          colorValue: const Value(0xFF00E676),
        ));
      } else {
        // [PERBAIKAN 2]: copyWith meminta data asli (String), JANGAN gunakan Value()
        await db.update(db.courses).replace(widget.courseToEdit!.copyWith(
          name: _nameController.text,
          day: _dayController.text,
          time: _timeController.text, // String is fine here for non-nullable
          room: Value(_roomController.text), // Needs Value() because room is nullable in schema
        ));
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      padding: EdgeInsets.only(left: 24, right: 24, top: 16, bottom: bottomInset + 16),
      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            
            // Nama Course (Besar tanpa border)
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: widget.courseToEdit != null ? "Edit Course Name" : "New Course Name", hintStyle: const TextStyle(color: Colors.white38), border: InputBorder.none),
            ),
            const Divider(color: Colors.white10),
            
            // Row Inputs (Kecil tanpa border)
            _buildIconInput(Icons.calendar_today, "Day (e.g., Monday)", _dayController),
            _buildIconInput(Icons.access_time, "Time (e.g., 08:00 AM)", _timeController),
            _buildIconInput(Icons.room_outlined, "Room (e.g., Lab 1)", _roomController),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF00E676),
                  radius: 24,
                  child: IconButton(icon: const Icon(Icons.check, color: Colors.black), onPressed: _saveCourse),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildIconInput(IconData icon, String hint, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24, fontSize: 14), border: InputBorder.none, isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}