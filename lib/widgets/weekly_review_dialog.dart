import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';

class WeeklyReviewDialog extends StatelessWidget {
  final List<Task> tasks;
  final VoidCallback onClose;

  const WeeklyReviewDialog({super.key, required this.tasks, required this.onClose});

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return '${DateFormat('M월 d일').format(d)} (${days[d.weekday % 7]})';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    // 날짜별 그룹핑
    final Map<String, List<Task>> grouped = {};
    for (final task in tasks) {
      grouped.putIfAbsent(task.date, () => []).add(task);
    }
    final sortedDates = grouped.keys.toList()..sort();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).padding.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('📋', style: TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('이번 주 미완료 항목', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                  Text('총 ${tasks.length}개를 완료하지 못했어요', style: const TextStyle(fontSize: 13, color: Color(0xFF999999))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: sortedDates.length,
              itemBuilder: (context, i) {
                final date = sortedDates[i];
                final dateTasks = grouped[date]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 8, bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_formatDate(date), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
                          Text('${dateTasks.length}개', style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
                        ],
                      ),
                    ),
                    ...dateTasks.map((task) {
                      final subject = provider.getSubjectById(task.subjectId);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 8, height: 8,
                              decoration: BoxDecoration(color: subject?.color ?? Colors.grey, shape: BoxShape.circle),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(task.title, style: const TextStyle(fontSize: 14, color: Color(0xFF333333)))),
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
                    }),
                  ],
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
              child: const Text('다음 주에는 꼭 해봐요!', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
