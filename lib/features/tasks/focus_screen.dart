// Lokasi: lib/features/tasks/focus_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';
import 'task_item_card.dart';
import 'add_task_sheet.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E676),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddTaskSheet(),
          );
        },
        child: const Icon(Icons.edit_note, color: Colors.black, size: 28),
      ),
      body: StreamBuilder<List<TypedResult>>(
        stream: (db.select(db.tasks).join([
          innerJoin(db.courses, db.courses.id.equalsExp(db.tasks.courseId)),
        ])..orderBy([OrderingTerm.asc(db.tasks.deadline)])).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final results = snapshot.data!;
          
          // Memisahkan Aktif dan Selesai
          final active = results.where((r) => !r.readTable(db.tasks).isCompleted).toList();
          final completed = results.where((r) => r.readTable(db.tasks).isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 100),
            children: [
              if (active.isEmpty && completed.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No tasks yet. Stay focused!", style: TextStyle(color: Colors.grey)))),              
              // Active Tasks
              ...active.map((res) => _buildDismissibleTask(context, db, res, false)),

              if (completed.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Text("COMPLETED", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
                ),
                // Completed Tasks (Dimmed)
                ...completed.map((res) => Opacity(
                  opacity: 0.5,
                  child: _buildDismissibleTask(context, db, res, true),
                )),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildDismissibleTask(BuildContext context, AppDatabase db, TypedResult res, bool isDone) {
    final task = res.readTable(db.tasks);
    final course = res.readTable(db.courses);

    return Dismissible(
      key: Key(task.id.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => db.deleteTask(task),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: TaskItemCard(task: task, course: course, isStrikethrough: isDone),
    );
  }
}