import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../widgets/glass_card.dart';

class WeeklySummaryScreen extends StatelessWidget {
  const WeeklySummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    // 이번 주 계산 (월요일 시작)
    final now = DateTime.now();
    final weekday = now.weekday;
    final monday = now.subtract(Duration(days: weekday - 1));
    final sunday = monday.add(const Duration(days: 6));

    // 이번 주 날짜 목록
    final weekDates = List.generate(7, (i) {
      final date = monday.add(Duration(days: i));
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    });

    // 이번 주 할 일 필터링
    final weekTasks = provider.tasks
        .where((t) => weekDates.contains(t.date))
        .toList();
    final completedTasks = weekTasks.where((t) => t.completed).toList();
    final uncompletedTasks = weekTasks.where((t) {
      // 미완료: 완료되지 않았고, 날짜가 오늘보다 이전인 것
      if (t.completed) return false;
      final taskDate = DateTime.parse(t.date);
      final today = DateTime(now.year, now.month, now.day);
      return taskDate.isBefore(today);
    }).toList();

    final totalTasks = weekTasks.length;
    final completedCount = completedTasks.length;
    final uncompletedCount = uncompletedTasks.length;
    final completionRate = totalTasks > 0
        ? (completedCount / totalTasks * 100).toStringAsFixed(0)
        : '0';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '이번 주 요약',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: textColor,
          ),
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 주간 통계 카드
            GlassCard(
              isDark: isDark,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        color: Color(0xFF4A90D9),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${DateFormat('M월 d일').format(monday)} - ${DateFormat('M월 d일').format(sunday)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          label: '전체',
                          value: '$totalTasks',
                          color: const Color(0xFF4A90D9),
                          icon: Icons.list_alt,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '완료',
                          value: '$completedCount',
                          color: const Color(0xFF52C41A),
                          icon: Icons.check_circle,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          label: '미완료',
                          value: '$uncompletedCount',
                          color: const Color(0xFFFF4D4F),
                          icon: Icons.cancel,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.trending_up,
                          color: Color(0xFF4A90D9),
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '완료율: $completionRate%',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4A90D9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 완료한 할 일
            if (completedTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF52C41A),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '완료한 할 일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF52C41A).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$completedCount개',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52C41A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: completedTasks
                      .map((task) => _TaskItem(task: task, showDelete: false))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 미완료한 할 일
            if (uncompletedTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    const Icon(
                      Icons.cancel,
                      color: Color(0xFFFF4D4F),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '미완료한 할 일',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4F).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$uncompletedCount개',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4D4F),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: uncompletedTasks
                      .map((task) => _TaskItem(task: task, showDelete: true))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            if (totalTasks == 0)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        '이번 주 할 일이 없어요',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final Task task;
  final bool showDelete;

  const _TaskItem({required this.task, required this.showDelete});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final subject = provider.getSubjectById(task.subjectId);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: task.completed
              ? const Color(0xFF52C41A).withValues(alpha: 0.2)
              : const Color(0xFFFF4D4F).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            task.completed ? Icons.check_circle : Icons.cancel,
            color: task.completed
                ? const Color(0xFF52C41A)
                : const Color(0xFFFF4D4F),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : const Color(0xFF333333),
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (subject != null) ...[
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: subject.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        subject.name,
                        style: TextStyle(
                          fontSize: 11,
                          color: subject.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      DateFormat('M/d').format(DateTime.parse(task.date)),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF999999),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (showDelete)
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                size: 18,
                color: Color(0xFFFF4D4F),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('할 일 삭제'),
                    content: Text('"${task.title}"을(를) 삭제하시겠습니까?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('취소'),
                      ),
                      TextButton(
                        onPressed: () {
                          provider.deleteTask(task.id);
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '삭제',
                          style: TextStyle(color: Color(0xFFFF4D4F)),
                        ),
                      ),
                    ],
                  ),
                );
              },
              tooltip: '삭제',
            ),
        ],
      ),
    );
  }
}
