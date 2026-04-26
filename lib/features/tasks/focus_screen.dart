import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:drift/drift.dart' hide Column;
import '../../core/database/app_database.dart';
import 'task_item_card.dart';
import 'add_task_sheet.dart';
import 'package:nyatettugas/core/services/notification_service.dart';

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
          showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddTaskSheet());
        },
        child: const Icon(Icons.edit_note, color: Colors.black, size: 28),
      ),
      body: StreamBuilder<List<TypedResult>>(
        stream: (db.select(db.tasks).join([innerJoin(db.courses, db.courses.id.equalsExp(db.tasks.courseId))])..orderBy([OrderingTerm.asc(db.tasks.deadline)])).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final results = snapshot.data!;
          final active = results.where((r) => !r.readTable(db.tasks).isCompleted).toList();
          final completed = results.where((r) => r.readTable(db.tasks).isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 100),
            children: [
              if (active.isEmpty && completed.isEmpty)
                const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No tasks yet. Chill bro...  ☕", style: TextStyle(color: Colors.grey)))),              
              
              ...active.map((res) => _buildSlidableTask(context, db, res, false)),

              if (completed.isNotEmpty) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Text("COMPLETED", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5))),
                ...completed.map((res) => Opacity(opacity: 0.5, child: _buildSlidableTask(context, db, res, true))),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSlidableTask(BuildContext context, AppDatabase db, TypedResult res, bool isDone) {
    final task = res.readTable(db.tasks);
    final course = res.readTable(db.courses);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(task.id),
        // HANYA SWIPE KIRI UNTUK EDIT & DELETE (Disamakan dengan Course)
        endActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            SlidableAction(
              onPressed: (context) {
                showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => AddTaskSheet(taskToEdit: task));
              },
              backgroundColor: const Color(0xFF2196F3),
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (context) async { // Batalkan notifikasi dulu baru hapus datanya
                await NotificationService().cancelNotification(task.id);
                await db.deleteTask(task);
                  },
              backgroundColor: const Color(0xFFFE4A49),
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
          ],
        ),
        child: TaskItemCard(task: task, course: course, isStrikethrough: isDone),
      ),
    );
  }
}