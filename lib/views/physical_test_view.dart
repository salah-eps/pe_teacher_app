import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PhysicalTestView extends StatefulWidget {
  final String studentId;
  final String studentName;

  const PhysicalTestView({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<PhysicalTestView> createState() => _PhysicalTestViewState();
}

class _PhysicalTestViewState extends State<PhysicalTestView> {
  final _supabase = Supabase.instance.client;
  final _scoreController = TextEditingController();
  String _selectedTestType = 'جري سريع (60م)';
  bool _isLoading = false;

  final List<String> _testTypes = [
    'جري سريع (60م)',
    'نصف طويل (600م/800م)',
    'الوثب الطويل',
    'دفع الجلة',
    'الجمباز',
    'الرياضات الجماعية',
  ];

  Future<void> _saveScore() async {
    if (_scoreController.text.trim().isEmpty) return;
    setState(() => _isLoading = true);
    try {
      await _supabase.from('test_results').insert({
        'student_id': widget.studentId,
        'test_type': _selectedTestType,
        'score': double.tryParse(_scoreController.text.trim()) ?? 0.0,
        'test_date': DateTime.now().toIso8601String(),
      });
      _scoreController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم حفظ النتيجة بنجاح!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في الحفظ: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('تقييم: ${widget.studentName}'),
        backgroundColor: Colors.teal.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('نوع الاختبار:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedTestType,
              items: _testTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedTestType = val!),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            const Text('النتيجة (رقم):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: 'أدخل التوقيت أو المسافة...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveScore,
                icon: const Icon(Icons.save),
                label: const Text('حفظ النتيجة'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const Divider(height: 40),
            const Text('السجل الأخير:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _supabase.from('test_results').stream(primaryKey: ['id']).eq('student_id', widget.studentId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                  final results = snapshot.data!;
                  if (results.isEmpty) {
                    return const Center(child: Text('لا توجد نتائج مسجلة لهذا التلميذ بعد.'));
                  }
                  return ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final res = results[index];
                      return ListTile(
                        leading: const Icon(Icons.history, color: Colors.teal),
                        title: Text(res['test_type']),
                        trailing: Text(res['score'].toString(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(res['test_date'].toString().split('T')[0]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
