import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/classes_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://xjnoexpouhrhnujejeen.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhqYm9leHBvdWhyaG51andqZW9uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODgxMjA5NDMsImV4cCI6MjEwMzY5Njk0M30.zwLgQo5HGWR7BKcnjtoME3pWkNIcFKvtce3d1oONOpg',
    );
  } catch (e) {
    debugPrint('Supabase Init Error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مساعد أستاذ التربية البدنية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const ClassesView(),
    );
  }
}
