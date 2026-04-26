import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:nyatettugas/core/utils/notification_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';
import '../../core/services/notification_service.dart';

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
  final _lecturerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.courseToEdit != null) {
      _nameController.text = widget.courseToEdit!.name;
      _dayController.text = widget.courseToEdit!.day;
      _timeController.text = widget.courseToEdit!.time;
      _roomController.text = widget.courseToEdit!.room ?? '';
      _lecturerController.text = widget.courseToEdit!.lecturer ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dayController.dispose();
    _timeController.dispose();
    _roomController.dispose();
    _lecturerController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    TimeOfDay initialTime = TimeOfDay.now();
    if (_timeController.text.isNotEmpty) {
      try {
        final parts = _timeController.text.split(':');
        initialTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1].split(' ')[0]));
      } catch (_) {}
    }

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: Color(0xFF00E676), onPrimary: Colors.black, surface: Color(0xFF1E1E1E), onSurface: Colors.white),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() => _timeController.text = picked.format(context));
    }
  }

  // --- MULAI PASTE LOGIKA WAKTU DI SINI ---
  int _getDayOfWeek(String dayString) {
    final lowerDay = dayString.trim().toLowerCase();
    if (lowerDay == 'senin' || lowerDay == 'monday') return 1;
    if (lowerDay == 'selasa' || lowerDay == 'tuesday') return 2;
    if (lowerDay == 'rabu' || lowerDay == 'wednesday') return 3;
    if (lowerDay == 'kamis' || lowerDay == 'thursday') return 4;
    if (lowerDay == 'jumat' || lowerDay == 'friday') return 5;
    if (lowerDay == 'sabtu' || lowerDay == 'saturday') return 6;
    if (lowerDay == 'minggu' || lowerDay == 'sunday') return 7;
    return 1; // Default
  }

  TimeOfDay _parseTime(String timeString) {
    try {
      final isPM = timeString.toLowerCase().contains('pm');
      final rawTime = timeString.replaceAll(RegExp(r'[^0-9:]'), '');
      final parts = rawTime.split(':');
      int hour = int.parse(parts[0]);
      int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      if (isPM && hour < 12) hour += 12;
      if (!isPM && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return const TimeOfDay(hour: 8, minute: 0); 
    }
  }
  // --- BATAS PASTE ---

  void _saveCourse() async {
    if (_nameController.text.isEmpty || _dayController.text.isEmpty || _timeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name, Day, and Time are required!'), backgroundColor: Colors.redAccent));
      return;
    }
    
    
    final db = context.read<AppDatabase>();

    try {
      int courseId; // Logika 1: Siapkan wadah ID

      if (widget.courseToEdit == null) {
        // Logika 2: Tangkap ID saat Insert
        courseId = await db.into(db.courses).insert(CoursesCompanion(
          name: Value(_nameController.text),
          day: Value(_dayController.text),
          time: Value(_timeController.text),
          room: Value(_roomController.text),
          lecturer: Value(_lecturerController.text),
          colorValue: const Value(0xFF00E676),
        ));
      } else {
        // Logika 3: Tangkap ID saat Update & Batalkan notif lama
        courseId = widget.courseToEdit!.id;
        await NotificationService().cancelNotification(courseId + 10000); 

        await db.update(db.courses).replace(widget.courseToEdit!.copyWith(
          name: _nameController.text,
          day: _dayController.text,
          time: _timeController.text, 
          room: Value(_roomController.text), 
          lecturer: Value(_lecturerController.text), 
        ));
      }

      // --- LOGIKA 4: PENJADWALAN NOTIF BERULANG & PESAN ACAK ---
      final prefs = await SharedPreferences.getInstance();
      int minutesBefore = prefs.getInt('course_reminder_val') ?? 15;
      
      int dayOfWeek = _getDayOfWeek(_dayController.text);
      TimeOfDay courseTime = _parseTime(_timeController.text);
      
      DateTime dummyDate = DateTime(2023, 1, 1, courseTime.hour, courseTime.minute);
      DateTime notifTime = dummyDate.subtract(Duration(minutes: minutesBefore));

      String roomName = _roomController.text.isNotEmpty ? _roomController.text : 'Ruangan TBA';
      String randomBody = NotificationHelper.getRandomCourseWarning(_nameController.text, roomName);

      await NotificationService().scheduleWeeklyNotification(
        id: courseId + 10000, 
        title: "Matkul Segera Mulai!",
        body: randomBody, // Pesan bahasa Inggris acak
        dayOfWeek: dayOfWeek,
        hour: notifTime.hour,
        minute: notifTime.minute,
      );

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
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: widget.courseToEdit != null ? "Edit Course Name" : "New Course Name", hintStyle: const TextStyle(color: Colors.white38), border: InputBorder.none),
            ),
            const Divider(color: Colors.white10),
            _buildIconInput(Icons.calendar_today, "Day (e.g., Senin/Monday)", _dayController),
            _buildIconInputTappable(Icons.access_time, "Time (e.g., 08:00 AM)", _timeController, _pickTime),
            _buildIconInput(Icons.room_outlined, "Room (e.g., Lab 1)", _roomController),
            _buildIconInput(Icons.person_outline, "Lecturer (e.g., Dr. Smith)", _lecturerController),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(backgroundColor: const Color(0xFF00E676), radius: 24, child: IconButton(icon: const Icon(Icons.check, color: Colors.black), onPressed: _saveCourse)),
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
          Expanded(child: TextField(controller: controller, style: const TextStyle(color: Colors.white, fontSize: 16), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24, fontSize: 14), border: InputBorder.none, isDense: true))),
        ],
      ),
    );
  }

  Widget _buildIconInputTappable(IconData icon, String hint, TextEditingController controller, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF00E676), size: 20),
          const SizedBox(width: 16),
          Expanded(child: TextField(controller: controller, readOnly: true, onTap: onTap, style: const TextStyle(color: Colors.white, fontSize: 16), decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: Colors.white24, fontSize: 14), border: InputBorder.none, isDense: true))),
        ],
      ),
    );
  }
}