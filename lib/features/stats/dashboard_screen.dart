import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- Import ini
import '../../core/database/app_database.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _userName = "Student";

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  void _loadName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('user_name') ?? "Student";
      if (_userName.isEmpty) _userName = "Student";
    });
  }

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
              // GREETING NAME DI SINI
              Text("Hello, $_userName!", style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text("Here's your productivity overview.", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              
              _buildProgressCard("Overall Productivity", progress, "${(progress * 100).toInt()}%"),
              const SizedBox(height: 32),
              const Text("STATISTICS", style: TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.5)),
              const SizedBox(height: 16),
              _buildSimpleStatRow("Active Tasks", (total - completed).toString(), Icons.pending_actions),
              _buildSimpleStatRow("Completed", completed.toString(), Icons.check_circle_outline),
              _buildSimpleStatRow("Total Tasks", total.toString(), Icons.assignment_outlined),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(String title, double value, String percentage) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              Text(percentage, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: value, minHeight: 12, backgroundColor: Colors.white10, color: const Color(0xFF00E676)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}