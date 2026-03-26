import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../widgets/add_task_modal.dart';

class DayDetailScreen extends StatelessWidget {
  final String date;

  const DayDetailScreen({super.key, required this.date});

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return '${DateFormat('yyyy년 M월 d일').format(d)} (${days[d.weekday % 7]})';
  }

  String _formatShortDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    return '${DateFormat('M월 d일').format(d)} (${days[d.weekday % 7]})';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final tasks = provider.getTasksForDate(date);
    final completedCount = tasks.where((t) => t.completed).length;
    final progress = tasks.isEmpty ? 0.0 : completedCount / tasks.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(_formatDate(date), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$completedCount/${tasks.length} 완료',
                style: const TextStyle(color: Color(0xFF4A90D9), fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 진행률 바
          LinearProgressIndicator(
            value: progress,
            backgroundColor: const Color(0xFFE0E0E0),
            color: const Color(0xFF52C41A),
            minHeight: 4,
          ),
          Expanded(
            child: tasks.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('이 날의 할 일이 없어요', style: TextStyle(fontSize: 16, color: Color(0xFF999999))),
                        SizedBox(height: 8),
                        Text('아래 버튼으로 추가해보세요', style: TextStyle(fontSize: 13, color: Color(0xFFBBBBBB))),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: tasks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return _TaskCard(task: task, formatShortDate: _formatShortDate);
                    },
                  ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, MediaQuery.of(context).padding.bottom + 16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => AddTaskModal(date: date),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90D9),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text('+ 할 일 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final String Function(String) formatShortDate;

  const _TaskCard({required this.task, required this.formatShortDate});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final subject = provider.getSubjectById(task.subjectId);

    return Opacity(
      opacity: task.completed ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1)),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: GestureDetector(
            onTap: () => provider.toggleTask(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.completed ? const Color(0xFF52C41A) : Colors.transparent,
                border: Border.all(
                  color: task.completed ? const Color(0xFF52C41A) : const Color(0xFFCCCCCC),
                  width: 2,
                ),
              ),
              child: task.completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF333333),
              decoration: task.completed ? TextDecoration.lineThrough : null,
              decorationColor: const Color(0xFF999999),
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              spacing: 6,
              children: [
                if (subject != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: subject.color, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 4),
                        Text(subject.name, style: TextStyle(fontSize: 12, color: subject.color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                if (task.carriedOver && task.originalDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${formatShortDate(task.originalDate!)}에서 이월',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF856404)),
                    ),
                  ),
                if (task.deadline != null) _DeadlineBadge(deadline: task.deadline!),
              ],
            ),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFFCCCCCC)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('할 일 삭제'),
                  content: Text('"${task.title}"을(를) 삭제할까요?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
                    TextButton(
                      onPressed: () {
                        provider.deleteTask(task.id);
                        Navigator.pop(context);
                      },
                      child: const Text('삭제', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final String deadline;
  const _DeadlineBadge({required this.deadline});

  @override
  Widget build(BuildContext context) {
    final d = DateTime.parse(deadline);
    final today = DateTime.now();
    final diff = d.difference(DateTime(today.year, today.month, today.day)).inDays;

    final Color color;
    final String label;
    final IconData icon;

    if (diff < 0) {
      color = const Color(0xFFFF4D4F);
      label = '${diff.abs()}일 초과';
      icon = Icons.warning_rounded;
    } else if (diff == 0) {
      color = const Color(0xFFFA8C16);
      label = '오늘 마감';
      icon = Icons.schedule;
    } else if (diff <= 3) {
      color = const Color(0xFFFFAD14);
      label = '$diff일 후 마감';
      icon = Icons.schedule;
    } else {
      color = const Color(0xFF999999);
      label = '${DateFormat('M/d').format(d)} 마감';
      icon = Icons.flag_outlined;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
