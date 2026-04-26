import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/app_database.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: StreamBuilder<List<Task>>(
        stream: db.select(db.tasks).watch(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final tasks = snapshot.data!;
          final now = DateTime.now();
          final today = DateTime(now.year, now.month, now.day);

          int activeCount = 0;
          int completedCount = 0;
          int overdueCount = 0;
          int todayCount = 0;

          for (var task in tasks) {
            if (task.isCompleted) {
              completedCount++;
            } else {
              activeCount++;
              final taskDate = DateTime(task.deadline.year, task.deadline.month, task.deadline.day);
              if (taskDate.isBefore(today)) {
                overdueCount++;
              } else if (taskDate.isAtSameMomentAs(today)) {
                todayCount++;
              }
            }
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              // HEADER & GREETING
              FutureBuilder<String>(
                future: SharedPreferences.getInstance().then((p) => p.getString('user_name') ?? 'Buddy'),
                builder: (context, nameSnapshot) {
                  final userName = nameSnapshot.data ?? 'Buddy';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hello, $userName! 👋", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Text("You have $activeCount active tasks waiting.", style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 40),

              // MINIMALIST STATS GRID
              Row(
                children: [
                  _buildStatBox("Overdue", overdueCount, Colors.redAccent, Icons.warning_amber_rounded),
                  const SizedBox(width: 16),
                  _buildStatBox("Today", todayCount, Colors.orangeAccent, Icons.today),
                  const SizedBox(width: 16),
                  _buildStatBox("Done", completedCount, const Color(0xFF00E676), Icons.check_circle_outline),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatBox(String title, int count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(count.toString(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}