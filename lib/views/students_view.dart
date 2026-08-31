import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'physical_test_view.dart';

class StudentsView extends StatefulWidget {
  final String classId;
  final String className;

  const StudentsView({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<StudentsView> createState() => _StudentsViewState();
}

class _StudentsViewState extends State<StudentsView> {
  final _supabase = Supabase.instance.client;
  final _fullNameController = TextEditingController();
  final _medicalStatusController = TextEditingController(text: 'سليم');
  String _selectedGender = 'male';
  bool _isLoading = false;

  Future<void> _addStudent() async {
    if (_fullNameController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _supabase.from('students').insert({
        'class_id': widget.classId,
        'full_name': _fullNameController.text.trim(),
        'gender': _selectedGender,
        'medical_status': _medicalStatusController.text.trim().isEmpty
            ? 'سليم'
            : _medicalStatusController.text.trim(),
      });
      _fullNameController.clear();
      _medicalStatusController.text = 'سليم';
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ أثناء إضافة التلميذ: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showAddStudentDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('إضافة تلميذ إلى ${widget.className}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم الكامل للتلميذ',
                  hintText: 'مثال: محمد بن علي',
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedGender,
                decoration: const InputDecoration(labelText: 'الجنس'),
                items: const [
                  DropdownMenuItem(value: 'male', child: Text('ذكر')),
                  DropdownMenuItem(value: 'female', child: Text('أنثى')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setDialogState(() => _selectedGender = value);
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _medicalStatusController,
                decoration: const InputDecoration(
                  labelText: 'الحالة الصحية',
                  hintText: 'سليم / يعاني من الربو...',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: _isLoading ? null : _addStudent,
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تلاميذ: ${widget.className}'),
        centerTitle: true,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _supabase
            .from('students')
            .stream(primaryKey: ['id'])
            .eq('class_id', widget.classId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final students = snapshot.data ?? [];
          if (students.isEmpty) {
            return const Center(
              child: Text('لا يوجد تلاميذ في هذا القسم بعد. اضغط + للإضافة.'),
            );
          }
          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              final isMale = student['gender'] == 'male';
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isMale ? Colors.blue.shade100 : Colors.pink.shade100,
                    child: Icon(
                      isMale ? Icons.boy : Icons.girl,
                      color: isMale ? Colors.blue : Colors.pink,
                    ),
                  ),
                  title: Text(
                    student['full_name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('الحالة الصحية: ${student['medical_status'] ?? 'سليم'}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhysicalTestView(
                          studentId: student['id'].toString(),
                          studentName: student['full_name'] ?? '',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('إضافة تلميذ'),
      ),
    );
  }
}
