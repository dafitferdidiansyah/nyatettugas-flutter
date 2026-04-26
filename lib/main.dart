import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/app_database.dart'; // Import database kita
import 'features/courses/add_course_sheet.dart';
import 'features/tasks/add_task_sheet.dart';
import 'features/tasks/focus_screen.dart';
import 'features/courses/course_archive_screen.dart';
import 'features/stats/dashboard_screen.dart';

void main() {
  // 1. Inisialisasi Database saat aplikasi pertama kali jalan
  final database = AppDatabase();

  runApp(
    // 2. Bungkus aplikasi dengan Provider agar database bisa diakses dari halaman manapun
    RepositoryProvider.value(
      value: database,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CourseTrak',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212),
        primaryColor: const Color(0xFF00E676),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF2979FF),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E676),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FocusScreen(),
    const CourseArchiveScreen(),   // Tab 1 (Matkul)
    const DashboardScreen(),       // Tab 2 (Stats)
    const Center(child: Text('Today\'s Focus', style: TextStyle(fontSize: 20, color: Colors.grey))),
    const Center(child: Text('Course Archive', style: TextStyle(fontSize: 20, color: Colors.grey))),
    const Center(child: Text('Stats & Progress', style: TextStyle(fontSize: 20, color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task.'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Focus'),
          BottomNavigationBarItem(icon: Icon(Icons.folder_copy_outlined), label: 'Archive'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: const Color(0xFF1E1E1E),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.book, color: Color(0xFF00E676)),
                    title: const Text('Add Course', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context); // Tutup menu pilihan dulu
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddCourseSheet());
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.task, color: Color(0xFF2979FF)),
                    title: const Text('Add Task', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      Navigator.pop(context); // Tutup menu pilihan dulu
                      showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AddTaskSheet());
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}