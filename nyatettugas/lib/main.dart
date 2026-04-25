import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NyatetTugas',
      debugShowCheckedModeBanner: false, // Menghilangkan pita merah 'DEBUG' di pojok
      themeMode: ThemeMode.dark, // Mengunci aplikasi ke Dark Mode permanen
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF121212), // Hitam pekat agar hemat baterai (OLED)
        primaryColor: const Color(0xFF00E676), // Warna aksen utama (Hijau Elektrik)
        
        // Konfigurasi warna secara global
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E676),
          secondary: Color(0xFF2979FF), // Biru untuk tombol opsional
          surface: Color(0xFF1E1E1E), // Warna untuk Card / Kotak
        ),
        
        // Konfigurasi AppBar (Header atas)
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0, // Datar, tanpa bayangan agar terlihat modern
          centerTitle: false,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2, // Jarak antar huruf agar estetik
          ),
        ),
        
        // Konfigurasi Tombol Mengambang (FAB)
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF00E676),
          foregroundColor: Colors.white,
        ),
      ),
      home: const MainScreen(),
    );
  }
}

// Layar Utama (Rangka Navigasi Bawah)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Placeholder untuk ke-3 halaman kita nanti
  final List<Widget> _pages = [
    const Center(child: Text('Today\'s Focus', style: TextStyle(fontSize: 20, color: Colors.grey))),
    const Center(child: Text('Course Archive', style: TextStyle(fontSize: 20, color: Colors.grey))),
    const Center(child: Text('Stats & Progress', style: TextStyle(fontSize: 20, color: Colors.grey))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task.'), // Nama aplikasi minimalis
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Arahkan ke halaman Settings
            },
          ),
        ],
      ),
      body: _pages[_currentIndex], // Menampilkan halaman sesuai tab yang dipilih
      
      // Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1E1E1E),
        selectedItemColor: const Color(0xFF00E676),
        unselectedItemColor: Colors.grey.shade600,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Mengganti tab saat diklik
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task_alt), 
            label: 'Focus'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_copy_outlined), 
            label: 'Archive'
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart), 
            label: 'Stats'
          ),
        ],
      ),
      
      // Tombol Tambah Global
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Buka Modal/Halaman tambah tugas baru
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}