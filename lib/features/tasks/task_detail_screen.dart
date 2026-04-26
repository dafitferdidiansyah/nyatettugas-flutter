import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../core/database/app_database.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;
  final Course course;

  const TaskDetailScreen({super.key, required this.task, required this.course});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descController; // <-- TAMBAHAN UNTUK DESKRIPSI
  late TextEditingController _notesController;
  String? _attachmentPath;
  String? _attachmentName;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? ''); // <-- LOAD DESKRIPSI
    _notesController = TextEditingController(text: widget.task.notes ?? '');
    _attachmentPath = widget.task.attachmentPath;
    _attachmentName = widget.task.attachmentName;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose(); // <-- DISPOSE DESKRIPSI
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleAutoSave() async {
    final db = context.read<AppDatabase>();
    await db.update(db.tasks).replace(
          widget.task.copyWith(
            title: _titleController.text,
            description: Value(_descController.text), // <-- AUTO SAVE DESKRIPSI
            notes: Value(_notesController.text),
            attachmentPath: Value(_attachmentPath),
            attachmentName: Value(_attachmentName),
          ),
        );
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.pickFiles();
    if (result != null && result.files.single.path != null) {
      setState(() {
        _attachmentPath = result.files.single.path;
        _attachmentName = result.files.single.name;
      });
      _handleAutoSave();
    }
  }

  void _deleteAttachment() {
    setState(() {
      _attachmentPath = null;
      _attachmentName = null;
    });
    _handleAutoSave();
  }

  void _openAttachment() {
    if (_attachmentPath != null) {
      OpenFilex.open(_attachmentPath!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) await _handleAutoSave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(widget.course.name, style: TextStyle(color: Color(widget.course.colorValue), fontSize: 14, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // EDITABLE TITLE
              TextField(
                controller: _titleController,
                maxLines: null,
                style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(
                  border: InputBorder.none, 
                  hintText: "Task Title", 
                  hintStyle: TextStyle(color: Colors.white38),
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 8),
                ),
              ),
              
              // EDITABLE DESCRIPTION (Warnanya lebih redup/abu-abu)
              TextField(
                controller: _descController,
                maxLines: null,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
                decoration: const InputDecoration(
                  border: InputBorder.none, 
                  hintText: "Add description...", 
                  hintStyle: TextStyle(color: Colors.white24),
                  isDense: true,
                  contentPadding: EdgeInsets.only(bottom: 12),
                ),
              ),
              
              const Divider(color: Colors.white10),
              
              // AREA NOTES
              Expanded(
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  expands: true,
                  style: const TextStyle(color: Colors.white, fontSize: 16, height: 1.6),
                  decoration: const InputDecoration(
                    hintText: "Start writing your notes...", 
                    hintStyle: TextStyle(color: Colors.white24), 
                    border: InputBorder.none
                  ),
                ),
              ),

              const SizedBox(height: 10),
              const Divider(color: Colors.white10),
              
              // AREA ATTACHMENT
              const Padding(
                padding: EdgeInsets.only(top: 10, bottom: 10),
                child: Text('Attachments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
              ),
              
              if (_attachmentName != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: const Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.insert_drive_file, color: Color(0xFF00E676)),
                    title: Text(_attachmentName!, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.redAccent), onPressed: _deleteAttachment),
                    onTap: _openAttachment,
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E1E1E), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.add_link),
                    label: const Text('Add Attachment'),
                  ),
                ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}