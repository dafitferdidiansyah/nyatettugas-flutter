import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';

class AddTaskSheet extends StatefulWidget {
  final Task? taskToEdit;
  const AddTaskSheet({super.key, this.taskToEdit});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  int? _selectedCourseId;
  DateTime _selectedDate = DateTime.now();
  bool _showDescField = false;

  @override
  void initState() {
    super.initState();
    if (widget.taskToEdit != null) {
      _titleController.text = widget.taskToEdit!.title;
      _descController.text = widget.taskToEdit!.description ?? '';
      _selectedDate = widget.taskToEdit!.deadline;
      _selectedCourseId = widget.taskToEdit!.courseId;
      if (_descController.text.isNotEmpty) _showDescField = true;
    }
  }

  void _saveTask() async {
    if (_titleController.text.isEmpty || _selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title and Course are required!'), backgroundColor: Colors.redAccent));
      return;
    }

    final db = context.read<AppDatabase>();
    if (widget.taskToEdit == null) {
      await db.into(db.tasks).insert(TasksCompanion.insert(
        courseId: _selectedCourseId!,
        title: _titleController.text,
        description: Value(_descController.text),
        deadline: _selectedDate,
        isCompleted: const Value(false),
      ));
    } else {
      await db.update(db.tasks).replace(widget.taskToEdit!.copyWith(
        courseId: _selectedCourseId!,
        title: _titleController.text,
        description: Value(_descController.text),
        deadline: _selectedDate,
      ));
    }
    if (mounted) Navigator.pop(context);
  }

  void _pickCourse(BuildContext context, AppDatabase db) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      builder: (context) => StreamBuilder<List<Course>>(
        stream: db.select(db.courses).watch(),
        builder: (context, snapshot) {
          final courses = snapshot.data ?? [];
          return ListView(
            padding: const EdgeInsets.all(20),
            shrinkWrap: true,
            children: [
              const Text("Select Course", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ...courses.map((c) => ListTile(
                leading: CircleAvatar(backgroundColor: Color(c.colorValue), radius: 6),
                title: Text(c.name, style: const TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => _selectedCourseId = c.id);
                  Navigator.pop(context);
                },
              ))
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.only(left: 20, right: 20, top: 16, bottom: bottomInset + 16),
      decoration: const BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 16),
            
            TextField(
              controller: _titleController,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              decoration: InputDecoration(hintText: widget.taskToEdit != null ? "Edit Task Title" : "What would you like to do?", hintStyle: const TextStyle(color: Colors.white38, fontSize: 18), border: InputBorder.none),
            ),
            
            if (_showDescField)
              TextField(
                controller: _descController,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                decoration: const InputDecoration(hintText: "Add description...", hintStyle: TextStyle(color: Colors.white24), border: InputBorder.none),
              ),

            Wrap(
              spacing: 8,
              children: [
                if (_selectedCourseId != null)
                  Chip(
                    backgroundColor: const Color(0xFF00E676).withOpacity(0.2),
                    label: const Text("Course Selected", style: TextStyle(color: Color(0xFF00E676), fontSize: 12)),
                    onDeleted: () => setState(() => _selectedCourseId = null),
                    deleteIconColor: const Color(0xFF00E676),
                    side: BorderSide.none,
                  ),
                Chip(
                  backgroundColor: Colors.white10,
                  label: Text("${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}", style: const TextStyle(color: Colors.white, fontSize: 12)),
                  avatar: const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.notes, color: _showDescField ? const Color(0xFF00E676) : Colors.grey),
                  onPressed: () => setState(() => _showDescField = !_showDescField),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, color: Colors.grey),
                  onPressed: () async {
                    final picked = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime(2030));
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.folder_outlined, color: _selectedCourseId != null ? const Color(0xFF00E676) : Colors.grey),
                  onPressed: () => _pickCourse(context, context.read<AppDatabase>()),
                ),
                const Spacer(),
                CircleAvatar(
                  backgroundColor: const Color(0xFF00E676),
                  radius: 24,
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.black), onPressed: _saveTask),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}