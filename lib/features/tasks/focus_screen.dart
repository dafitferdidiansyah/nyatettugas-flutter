import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/app_database.dart';
import 'package:drift/drift.dart' hide Column;
import 'task_item_card.dart';
import 'task_detail_screen.dart';

class FocusScreen extends StatelessWidget {
  const FocusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<TypedResult>>(
        // Algoritma: Ambil tugas, gabungkan (join) dengan data matkul
        stream: (db.select(db.tasks)..where((t) => t.isCompleted.equals(false)))
            .join([
              innerJoin(db.courses, db.courses.id.equalsExp(db.tasks.courseId)),
            ]).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final results = snapshot.data!;
          if (results.isEmpty) {
            return const Center(child: Text("No tasks for today. Chill! ☕", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final row = results[index];
              final task = row.readTable(db.tasks);
              final course = row.readTable(db.courses);

              return TaskItemCard(
                task: task,
                course: course,
                onCheckboxChanged: (val) {
                  // Update status selesai di database
                  db.update(db.tasks).replace(task.copyWith(isCompleted: val ?? false));
                },
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task, course: course),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}