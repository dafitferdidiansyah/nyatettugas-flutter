// Lokasi: lib/core/utils/notification_helper.dart
import 'dart:math';

class NotificationHelper {
  static final _random = Random();

  // Kumpulan kata-kata peringatan untuk Tugas
  static const List<String> _taskWarnings = [
    "Friendly reminder: '{task}' is due soon. You've got this!",
    "Don't let '{task}' slip away! Check your progress now.",
    "Quick update: The deadline for '{task}' is approaching.",
    "Focus mode on! Time to wrap up '{task}'.",
    "Keep the momentum! '{task}' needs your attention.",
  ];

  // Kumpulan kata-kata peringatan untuk Matkul/Course
  static const List<String> _courseWarnings = [
    "Class incoming! '{course}' starts soon in {room}.",
    "Prepare your notes for the '{course}' session today.",
    "Time to head to {room} for '{course}'. See you there!",
    "Get ready! Your '{course}' lecture is about to begin.",
  ];

  // Fungsi pemanggil Acak untuk Tugas
  static String getRandomTaskWarning(String taskName) {
    final template = _taskWarnings[_random.nextInt(_taskWarnings.length)];
    return template.replaceAll('{task}', taskName);
  }

  // Fungsi pemanggil Acak untuk Matkul
  static String getRandomCourseWarning(String courseName, String room) {
    final template = _courseWarnings[_random.nextInt(_courseWarnings.length)];
    return template.replaceAll('{course}', courseName).replaceAll('{room}', room);
  }
}