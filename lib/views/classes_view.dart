import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClassesView extends StatefulWidget {
  const ClassesView({super.key});

  @override
  State<ClassesView> createState() => _ClassesViewState();
}

class _ClassesViewState extends State<ClassesView> {
  final _supabase = Supabase.instance.client;
  final _classNameController = TextEditingController();
  final _yearController = TextEditingController(text: '2026/2027');
  bool _isLoading = false;

  Future<void> _addClass() async {
    if (_classNameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      final userId = _supabase.auth.currentUser?.id ?? '00000000-0000-0000-0000-000000000000';
      await _supabase.from('classes').insert({
        'teacher_id': userId,
        'class_name': _classNameController.text.trim(),
        'academic_year': _yearController.text.trim(),
      });
      _classNameController.clear();
      if (mounted) Navigator.pop(context);
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء الإضافة: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddClassDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة قسم جديد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _classNameController,
              decoration: const InputDecoration(
                labelText: 'اسم القسم',
                hintText: 'مثال: 1 متوسط 1',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _yearController,
              decoration: const InputDecoration(labelText: 'السنة الدراسية'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _addClass,
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قائمة الأقسام والصفوف'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase.from('classes').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final classes = snapshot.data ?? [];
          if (classes.isEmpty) {
            return const Center(child: Text('لا توجد أقسام مضافة بعد. اضغط + للإضافة.'));
          }
          return ListView.builder(
            itemCount: classes.length,
            itemBuilder: (context, index) {
              final item = classes[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.class_outlined),
                  ),
                  title: Text(
                    item['class_name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('الموسم: ${item['academic_year']}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // سيتم توجيهه لصفحة قائمة تلاميذ هذا القسم
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddClassDialog,
        icon: const Icon(Icons.add),
        label: const Text('إضافة قسم'),
      ),
    );
  }
}
