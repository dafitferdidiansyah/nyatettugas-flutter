import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/database/app_database.dart';
import 'features/settings/settings_screen.dart';
import 'features/courses/course_archive_screen.dart';
import 'features/stats/dashboard_screen.dart';
import 'features/tasks/focus_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'core/services/notification_service.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init(); // <--- TAMBAHKAN INI
  runApp(
    RepositoryProvider(
      create: (context) => AppDatabase(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NyatetTugas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xFF00E676),
        useMaterial3: true,
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

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  void _requestPermissions() async {
    // Minta izin kirim notif (Wajib di Android 13+)
    await Permission.notification.request();
  }

  int _currentIndex = 0;

  final List<Widget> _pages = [
    const FocusScreen(),           // 0: Task List
    const CourseArchiveScreen(),   // 1: Kategori/Matkul
    const DashboardScreen(),       // 2: Analytics
  ];

  final List<String> _titles = ["Task", "Courses", "Dashboard"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _titles[_currentIndex], 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context, 
                MaterialPageRoute(builder: (context) => const SettingsScreen())
              );
            },
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.white10, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: const Color(0xFF121212),
          selectedItemColor: const Color(0xFF00E676),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.task_alt), label: 'Task'),
            BottomNavigationBarItem(icon: Icon(Icons.folder_open), label: 'Courses'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dashboard'),
          ],
        ),
      ),
    );
  }
}