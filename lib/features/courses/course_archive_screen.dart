// Lokasi: lib/features/courses/course_archive_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const AddCourseSheet(),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: StreamBuilder<List<Course>>(
        stream: db.select(db.courses).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const Center(child: Text("No courses available. Tap + to add.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.separated(
            padding: const EdgeInsets.only(top: 10, left: 20, right: 20, bottom: 90),
            itemCount: courses.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final course = courses[index];
              
              // MEMBUNGKUS CONTAINER DENGAN DISMISSIBLE
              return Dismissible(
                key: Key(course.id.toString()),
                direction: DismissDirection.endToStart, // Geser dari kanan ke kiri
                onDismissed: (dir) => db.deleteCourse(course),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Colors.redAccent, 
                    borderRadius: BorderRadius.circular(16)
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10, width: 1),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    // Indikator Warna di sisi kiri
                    leading: Container(
                      width: 6,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Color(course.colorValue),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    title: Text(
                      course.name,
                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          const Icon(Icons.schedule, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Text(course.day, style: const TextStyle(color: Colors.grey, fontSize: 13)), 
                        ],
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Colors.white24),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}