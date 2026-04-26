import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Untuk buka file native
import '../../core/database/app_database.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final Course course;

  const TaskDetailScreen({super.key, required this.task, required this.course});

  // Algoritma Buka File Native MIUI
  void _openFile(String path) async {
    final Uri uri = Uri.file(path);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $path');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Assignment Detail')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(course.name, style: const TextStyle(color: Color(0xFF00E676), fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(task.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 20),
            const Text('Attachments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            
            // Contoh Tampilan Attachment (Nanti kita ambil dari database)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
                title: const Text('Materi_Kuliah.pdf', style: TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.open_in_new, color: Colors.grey),
                onTap: () {
                  // _openFile('/storage/emulated/0/Download/Materi_Kuliah.pdf');
                },
              ),
            ),
            
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E), foregroundColor: Colors.white),
                onPressed: () {
                  // TODO: Panggil FilePicker
                },
                icon: const Icon(Icons.add_link),
                label: const Text('Add Attachment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}