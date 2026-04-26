import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Course course;

  const TaskDetailScreen({super.key, required this.task, required this.course});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.task.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAutoSave() async {
    final db = context.read<AppDatabase>();
    await db.update(db.tasks).replace(
          widget.task.copyWith(notes: Value(_notesController.text)),
        );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          await _handleAutoSave(); // Auto-save saat user kembali (back)
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212), // Tetap pertahankan dark style
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.course.name, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.task.title,
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  expands: true,
                  autofocus: true, // INI KUNCI PERBAIKANNYA BIAR TIDAK BEKU
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: "Start writing your notes...",
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}