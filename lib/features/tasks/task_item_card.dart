// Lokasi: lib/features/tasks/task_item_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../core/database/app_database.dart';
import 'task_detail_screen.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final Course course;
  final bool isStrikethrough;

  const TaskItemCard({super.key, required this.task, required this.course, this.isStrikethrough = false});

  void _shareTask() {
    final String content = """
📌 *Task:* ${task.title}
📚 *Course:* ${course.name}
📅 *Deadline:* ${task.deadline.day}/${task.deadline.month}/${task.deadline.year}
📝 *Notes:* ${task.notes ?? '-'}
    """;
    Share.share(content);
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Container(
        decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TaskDetailScreen(task: task, course: course))),        leading: Checkbox(
          value: task.isCompleted,
          activeColor: const Color(0xFF00E676),
          onChanged: (val) => db.updateTaskStatus(task, val ?? false),
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            decoration: isStrikethrough ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(course.name, style: TextStyle(color: Color(course.colorValue), fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.share_outlined, color: Colors.white38, size: 20),
          onPressed: _shareTask,
        ),
      ),
    );
  }
}