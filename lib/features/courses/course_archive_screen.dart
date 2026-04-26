import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../core/database/app_database.dart';
import 'add_course_sheet.dart';

class CourseArchiveScreen extends StatelessWidget {
  const CourseArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00E676),
        onPressed: () => _showForm(context),
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<Course>>(
        stream: db.select(db.courses).watch(),
        builder: (context, snapshot) {
          final courses = snapshot.data ?? [];
          if (courses.isEmpty) {
            return const Center(child: Padding(padding: EdgeInsets.only(top: 50), child: Text("No courses yet. Stay focused!", style: TextStyle(color: Colors.grey))));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final course = courses[index];
              return Slidable(
                key: ValueKey(course.id),
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) => _showForm(context, course: course),
                      backgroundColor: const Color(0xFF2196F3),
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (context) => db.deleteCourse(course),
                      backgroundColor: const Color(0xFFFE4A49),
                      icon: Icons.delete,
                      label: 'Delete',
                      borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
                    ),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(width: 4, height: 40, decoration: BoxDecoration(color: Color(course.colorValue), borderRadius: BorderRadius.circular(2))),
                    title: Text(course.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    subtitle: Text("${course.day} • ${course.time} • ${course.room ?? 'No Room'}", style: const TextStyle(color: Colors.grey)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showForm(BuildContext context, {Course? course}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddCourseSheet(courseToEdit: course),
    );
  }
}