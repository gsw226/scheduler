import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';

class CarryOverDialog extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onClose;

  const CarryOverDialog({super.key, required this.tasks, required this.onClose});

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return '${DateFormat('M월 d일').format(d)} (${days[d.weekday % 7]})';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text('어제 못다 한 것이 있어요', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text('아래 항목이 오늘 목록에 추가되었습니다', style: TextStyle(fontSize: 13, color: Color(0xFF999999))),
            const SizedBox(height: 20),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 250),
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: tasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF5F5F5)),
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  final subject = provider.getSubjectById(task.subjectId);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          width: 8, height: 8,
                          decoration: BoxDecoration(
                            color: subject?.color ?? Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(task.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              if (task.originalDate != null)
                                Text(_formatDate(task.originalDate!), style: const TextStyle(fontSize: 11, color: Color(0xFF999999))),
                            ],
                          ),
                        ),
                        if (subject != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: subject.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(subject.name, style: TextStyle(fontSize: 11, color: subject.color, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('확인했어요', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
