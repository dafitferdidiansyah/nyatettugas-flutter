import 'dart:convert';
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

class _TaskDetailScreenState extends State<TaskDetailScreen>
    with SingleTickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _descController;
  late TextEditingController _notesController;

  List<String> _attachmentPaths = [];
  List<String> _attachmentNames = [];

  // ── State panel attachment ──────────────────────────────────────────────────
  bool _isPanelExpanded = false;
  late AnimationController _animController;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descController = TextEditingController(text: widget.task.description ?? '');
    _notesController = TextEditingController(text: widget.task.notes ?? '');

    // Load multi-attachment dari JSON string
    if (widget.task.attachmentPath != null &&
        widget.task.attachmentPath!.isNotEmpty) {
      try {
        _attachmentPaths =
            List<String>.from(jsonDecode(widget.task.attachmentPath!));
        _attachmentNames =
            List<String>.from(jsonDecode(widget.task.attachmentName!));
      } catch (e) {
        _attachmentPaths = [widget.task.attachmentPath!];
        _attachmentNames = [widget.task.attachmentName ?? 'Attachment'];
      }
    }

    // Animasi expand/collapse panel
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _notesController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() => _isPanelExpanded = !_isPanelExpanded);
    if (_isPanelExpanded) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  Future<void> _handleAutoSave() async {
    final db = context.read<AppDatabase>();
    await db.update(db.tasks).replace(
          widget.task.copyWith(
            title: _titleController.text,
            description: Value(_descController.text),
            notes: Value(_notesController.text),
            attachmentPath: Value(jsonEncode(_attachmentPaths)),
            attachmentName: Value(jsonEncode(_attachmentNames)),
          ),
        );
  }

  Future<void> _pickAttachment() async {
    FilePickerResult? result = await FilePicker.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        for (var file in result.files) {
          if (file.path != null) {
            _attachmentPaths.add(file.path!);
            _attachmentNames.add(file.name);
          }
        }
        // Auto-expand saat ada file baru
        if (!_isPanelExpanded) {
          _isPanelExpanded = true;
          _animController.forward();
        }
      });
      _handleAutoSave();
    }
  }

  void _deleteAttachment(int index) {
    setState(() {
      _attachmentPaths.removeAt(index);
      _attachmentNames.removeAt(index);
      // Collapse otomatis kalau list sudah kosong
      if (_attachmentPaths.isEmpty && _isPanelExpanded) {
        _isPanelExpanded = false;
        _animController.reverse();
      }
    });
    _handleAutoSave();
  }

  void _openAttachment(String path) => OpenFilex.open(path);

  // ── Satu chip attachment (kartu kecil horizontal) ──────────────────────────
  Widget _buildAttachmentChip(int index) {
    // Tentukan icon & warna berdasarkan ekstensi file
    final ext = _attachmentNames[index].split('.').last.toLowerCase();
    final (IconData icon, Color color) = switch (ext) {
      'pdf' => (Icons.picture_as_pdf, Colors.redAccent),
      'jpg' || 'jpeg' || 'png' || 'gif' || 'webp' => (Icons.image, Colors.blueAccent),
      'doc' || 'docx' => (Icons.description, const Color(0xFF2196F3)),
      'xls' || 'xlsx' => (Icons.table_chart, Colors.green),
      'ppt' || 'pptx' => (Icons.slideshow, Colors.orangeAccent),
      'zip' || 'rar' || '7z' => (Icons.folder_zip, Colors.amber),
      _ => (Icons.insert_drive_file, const Color(0xFF00E676)),
    };

    return GestureDetector(
      onTap: () => _openAttachment(_attachmentPaths[index]),
      child: Container(
        width: 110,
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF252525),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 22),
                GestureDetector(
                  onTap: () => _deleteAttachment(index),
                  child: const Icon(Icons.close, color: Colors.white38, size: 14),
                ),
              ],
            ),
            const Spacer(),
            Text(
              _attachmentNames[index],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              ext.toUpperCase(),
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // ── Sticky bottom panel dengan toggle ─────────────────────────────────────
  Widget _buildAttachmentPanel() {
    final hasFiles = _attachmentPaths.isNotEmpty;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header bar (selalu terlihat, bisa di-tap untuk toggle) ──────
          InkWell(
            onTap: hasFiles ? _togglePanel : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
              child: Row(
                children: [
                  // Drag handle indicator
                  Container(
                    width: 32,
                    height: 3,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const Icon(Icons.attach_file, color: Colors.grey, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    'Attachments',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (hasFiles) ...[
                    const SizedBox(width: 8),
                    // Badge jumlah file
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E676).withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_attachmentPaths.length}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF00E676),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  // Tombol tambah (selalu visible di header)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF00E676),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      backgroundColor: const Color(0xFF00E676).withOpacity(0.1),
                    ),
                    onPressed: _pickAttachment,
                    icon: const Icon(Icons.add, size: 14),
                    label: const Text('Add', style: TextStyle(fontSize: 12)),
                  ),
                  // Chevron toggle (hanya muncul kalau ada file)
                  if (hasFiles) ...[
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _isPanelExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(Icons.keyboard_arrow_up, color: Colors.white38, size: 18),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Expanded area: horizontal scroll chips ───────────────────────
          SizeTransition(
            sizeFactor: _expandAnim,
            child: hasFiles
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
                    child: SizedBox(
                      height: 108,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _attachmentPaths.length,
                        itemBuilder: (context, index) =>
                            _buildAttachmentChip(index),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Panel hilang saat keyboard terbuka agar tidak berebut ruang
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) await _handleAutoSave();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF121212),

        // ── Sticky attachment panel di bawah ─────────────────────────────
        bottomNavigationBar: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          transitionBuilder: (child, anim) =>
              SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(anim),
                child: FadeTransition(opacity: anim, child: child),
              ),
          child: keyboardOpen
              ? const SizedBox.shrink(key: ValueKey('hidden'))
              : KeyedSubtree(
                  key: const ValueKey('panel'),
                  child: _buildAttachmentPanel(),
                ),
        ),

        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            widget.course.name,
            style: TextStyle(
              color: Color(widget.course.colorValue),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),

        // ── Body: Title + Desc + Notes ───────────────────────────────────
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section (fixed)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 10, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    maxLines: null,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "Task Title",
                      hintStyle: TextStyle(color: Colors.white38),
                      isDense: true,
                      contentPadding: EdgeInsets.only(bottom: 8),
                    ),
                  ),
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
                ],
              ),
            ),

            // Notes area: selalu lega, bisa scroll mandiri
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: TextField(
                  controller: _notesController,
                  maxLines: null,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.6,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Start writing your notes...",
                    hintStyle: TextStyle(color: Colors.white24),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}