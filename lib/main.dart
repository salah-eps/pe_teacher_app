import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'views/classes_view.dart';

void main() async {
  // 1. تأكيد تهيئة محرك فلاتر قبل أي عملية أخرى
  WidgetsFlutterBinding.ensureInitialized();

  // 2. محاولة الاتصال بـ Supabase مع حماية التطبيق من التجمُّد عند انقطاع النت
  try {
    await Supabase.initialize(
      url: 'https://YOUR_SUPABASE_PROJECT_URL.supabase.co', // ضع رابط Supabase الخاص بك هنا
      anonKey: 'YOUR_SUPABASE_ANON_KEY', // ضع مفتاح Anon الخاص بك هنا
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
