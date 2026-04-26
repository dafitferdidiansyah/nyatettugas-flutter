import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          final completed = tasks.where((t) => t.isCompleted).length;
          final total = tasks.length;
          final progress = total == 0 ? 0.0 : completed / total;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text("Your Progress", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              
              // KARTU STATISTIK UTAMA
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF00E676), Color(0xFF00C853)]),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total Tugas Selesai", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        Text("$completed/$total", style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 15),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.black12,
                      color: Colors.black,
                      minHeight: 10,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    const SizedBox(height: 10),
                    Text("${(progress * 100).toInt()}% Selesai", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              
              const SizedBox(height: 30),
              const Text("Tips Hari Ini", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              const ListTile(
                leading: Icon(Icons.lightbulb, color: Colors.yellow),
                title: Text("Cicil tugas yang deadline-nya paling dekat dulu, Dafit!", style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          );
        },
      ),
    );
  }
}