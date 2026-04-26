import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/database/app_database.dart';

class CourseArchiveScreen extends StatelessWidget {
  const CourseArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Course>>(
        stream: db.select(db.courses).watch(), // Ambil data matkul secara realtime
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          
          final courses = snapshot.data!;
          if (courses.isEmpty) {
            return const Center(child: Text("Belum ada matkul. Klik + untuk tambah!", style: TextStyle(color: Colors.grey)));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Tampilan 2 kolom
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
            ),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Container(
                decoration: BoxDecoration(
                  color: Color(course.colorValue).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Color(course.colorValue).withOpacity(0.5), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.book_rounded, color: Color(course.colorValue), size: 40),
                    const SizedBox(height: 12),
                    Text(
                      course.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      course.day,
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}