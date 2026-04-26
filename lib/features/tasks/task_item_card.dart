import 'package:flutter/material.dart';
import '../../core/database/app_database.dart';

class TaskItemCard extends StatelessWidget {
  final Task task;
  final Course course;
  final Function(bool?) onCheckboxChanged;
  final VoidCallback onTap;

  const TaskItemCard({
    super.key,
    required this.task,
    required this.course,
    required this.onCheckboxChanged,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell( // Bungkus dengan InkWell
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ListTile(
          leading: Transform.scale(
            scale: 1.2,
            child: Checkbox(
              value: task.isCompleted,
              onChanged: onCheckboxChanged,
              activeColor: const Color(0xFF00E676),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted ? Colors.grey : Colors.white,
            ),
          ),
          subtitle: Text(
            course.name,
            style: TextStyle(color: Color(course.colorValue).withOpacity(0.8), fontSize: 12),
          ),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ),
    );
  }
}