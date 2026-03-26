import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/subject.dart';
import '../models/task.dart';
import 'day_detail_screen.dart';

const _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

class SubjectDetailScreen extends StatefulWidget {
  final Subject subject;
  const SubjectDetailScreen({super.key, required this.subject});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 7,
      vsync: this,
      initialIndex: _todayWeekdayIndex(),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int _todayWeekdayIndex() {
    // DateTime.weekday: 1=월 ~ 7=일 → 탭 인덱스 0~6
    return DateTime.now().weekday - 1;
  }

  // 특정 요일(1=월~7=일)에 해당하는 날짜들의 할 일 가져오기
  List<Task> _getTasksForWeekday(List<Task> allTasks, int weekday) {
    return allTasks.where((t) {
      try {
        return DateTime.parse(t.date).weekday == weekday;
      } catch (_) {
        return false;
      }
    }).toList()..sort((a, b) => a.date.compareTo(b.date));
  }

  String _formatDate(String dateStr) {
    final d = DateTime.parse(dateStr);
    return DateFormat('M/d').format(d);
  }

  // 마감일 상태 계산
  DeadlineStatus _getDeadlineStatus(String? deadline) {
    if (deadline == null) return DeadlineStatus.none;
    final d = DateTime.parse(deadline);
    final today = DateTime.now();
    final diff = d
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (diff < 0) return DeadlineStatus.overdue;
    if (diff == 0) return DeadlineStatus.today;
    if (diff <= 3) return DeadlineStatus.soon;
    return DeadlineStatus.normal;
  }

  String _deadlineLabel(String deadline) {
    final d = DateTime.parse(deadline);
    final today = DateTime.now();
    final diff = d
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;
    if (diff < 0) return '${diff.abs()}일 초과';
    if (diff == 0) return '오늘 마감';
    if (diff == 1) return '내일 마감';
    return '${DateFormat('M/d').format(d)} 마감';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    final subjectTasks = provider.tasks
        .where((t) => t.subjectId == widget.subject.id)
        .toList();
    final completedCount = subjectTasks.where((t) => t.completed).length;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.subject.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.subject.name,
              style: TextStyle(fontWeight: FontWeight.w700, color: textColor),
            ),
          ],
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: _weekdays.map((d) => Tab(text: d)).toList(),
          labelColor: widget.subject.color,
          unselectedLabelColor: isDark
              ? Colors.white38
              : const Color(0xFF999999),
          indicatorColor: widget.subject.color,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          // 과목 요약
          Container(
            color: cardColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _StatChip(
                  label: '전체',
                  value: '${subjectTasks.length}개',
                  color: isDark ? Colors.white70 : const Color(0xFF666666),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: '완료',
                  value: '$completedCount개',
                  color: const Color(0xFF52C41A),
                ),
                const SizedBox(width: 12),
                _StatChip(
                  label: '미완료',
                  value: '${subjectTasks.length - completedCount}개',
                  color: const Color(0xFFFA8C16),
                ),
                const Spacer(),
                // 마감 임박 뱃지
                Builder(
                  builder: (_) {
                    final overdue = subjectTasks
                        .where(
                          (t) =>
                              !t.completed &&
                              t.deadline != null &&
                              _getDeadlineStatus(t.deadline) ==
                                  DeadlineStatus.overdue,
                        )
                        .length;
                    if (overdue == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF4D4F).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '마감 초과 $overdue개',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFFFF4D4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          // 요일별 탭
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: List.generate(7, (i) {
                final weekday = i + 1; // 1=월 ~ 7=일
                final dayTasks = _getTasksForWeekday(subjectTasks, weekday);

                return _WeekdayTab(
                  weekday: weekday,
                  tasks: dayTasks,
                  subject: widget.subject,
                  formatDate: _formatDate,
                  deadlineLabel: _deadlineLabel,
                  getDeadlineStatus: _getDeadlineStatus,
                  onAddTask: () => _showAddTaskForDay(context, weekday),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTaskForDay(BuildContext context, int weekday) {
    // 해당 요일의 가장 가까운 미래 날짜 계산
    final now = DateTime.now();
    int daysUntil = (weekday - now.weekday) % 7;
    if (daysUntil == 0) daysUntil = 0; // 오늘
    final targetDate = now.add(Duration(days: daysUntil));
    final dateStr = _dateStrFromDateTime(targetDate);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskWithDeadlineModal(
        date: dateStr,
        subjectId: widget.subject.id,
        subjectColor: widget.subject.color,
        subjectName: widget.subject.name,
      ),
    );
  }

  String _dateStrFromDateTime(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF999999)),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _WeekdayTab extends StatelessWidget {
  final int weekday;
  final List<Task> tasks;
  final Subject subject;
  final String Function(String) formatDate;
  final String Function(String) deadlineLabel;
  final DeadlineStatus Function(String?) getDeadlineStatus;
  final VoidCallback onAddTask;

  const _WeekdayTab({
    required this.weekday,
    required this.tasks,
    required this.subject,
    required this.formatDate,
    required this.deadlineLabel,
    required this.getDeadlineStatus,
    required this.onAddTask,
  });

  @override
  Widget build(BuildContext context) {
    // 날짜별로 그룹핑
    final Map<String, List<Task>> grouped = {};
    for (final t in tasks) {
      grouped.putIfAbsent(t.date, () => []).add(t);
    }
    final sortedDates = grouped.keys.toList()..sort();

    return Column(
      children: [
        Expanded(
          child: tasks.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note,
                        size: 48,
                        color: subject.color.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        '이 요일엔 할 일이 없어요',
                        style: TextStyle(
                          fontSize: 15,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, i) {
                    final date = sortedDates[i];
                    final dateTasks = grouped[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 날짜 헤더 (탭하면 DayDetailScreen으로)
                        GestureDetector(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DayDetailScreen(date: date),
                            ),
                          ),
                          child: Container(
                            margin: EdgeInsets.only(
                              bottom: 8,
                              top: i == 0 ? 0 : 12,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: subject.color.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  formatDate(date),
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: subject.color,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${dateTasks.where((t) => t.completed).length}/${dateTasks.length} 완료',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: subject.color.withValues(alpha: 0.7),
                                  ),
                                ),
                                const Spacer(),
                                Icon(
                                  Icons.chevron_right,
                                  size: 16,
                                  color: subject.color,
                                ),
                              ],
                            ),
                          ),
                        ),
                        ...dateTasks.map(
                          (task) => _TaskRow(
                            task: task,
                            subject: subject,
                            deadlineLabel: deadlineLabel,
                            deadlineStatus: getDeadlineStatus(task.deadline),
                          ),
                        ),
                      ],
                    );
                  },
                ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            0,
            16,
            MediaQuery.of(context).padding.bottom + 16,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAddTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: subject.color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                '+ 할 일 추가',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TaskRow extends StatelessWidget {
  final Task task;
  final Subject subject;
  final String Function(String) deadlineLabel;
  final DeadlineStatus deadlineStatus;

  const _TaskRow({
    required this.task,
    required this.subject,
    required this.deadlineLabel,
    required this.deadlineStatus,
  });

  Color get _deadlineColor {
    switch (deadlineStatus) {
      case DeadlineStatus.overdue:
        return const Color(0xFFFF4D4F);
      case DeadlineStatus.today:
        return const Color(0xFFFA8C16);
      case DeadlineStatus.soon:
        return const Color(0xFFFFAD14);
      default:
        return const Color(0xFF999999);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final isDark = provider.isDarkMode;
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;

    return Opacity(
      opacity: task.completed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: task.completed
              ? (isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9))
              : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: task.completed
                ? const Color(0xFFE0E0E0)
                : subject.color.withValues(alpha: 0.3),
          ),
        ),
        child: ListTile(
          dense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: GestureDetector(
            onTap: () => provider.toggleTask(task.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: task.completed
                    ? const Color(0xFF52C41A)
                    : Colors.transparent,
                border: Border.all(
                  color: task.completed
                      ? const Color(0xFF52C41A)
                      : const Color(0xFFCCCCCC),
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
              color: task.completed
                  ? const Color(0xFF999999)
                  : (isDark ? Colors.white : const Color(0xFF333333)),
              decoration: task.completed ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: task.deadline != null
              ? Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Row(
                    children: [
                      Icon(
                        deadlineStatus == DeadlineStatus.overdue
                            ? Icons.warning_rounded
                            : Icons.schedule,
                        size: 12,
                        color: _deadlineColor,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        deadlineLabel(task.deadline!),
                        style: TextStyle(
                          fontSize: 11,
                          color: _deadlineColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : null,
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 16, color: Color(0xFFCCCCCC)),
            onPressed: () => provider.deleteTask(task.id),
          ),
        ),
      ),
    );
  }
}

enum DeadlineStatus { none, normal, soon, today, overdue }

// 마감일 포함 할 일 추가 모달
class _AddTaskWithDeadlineModal extends StatefulWidget {
  final String date;
  final String subjectId;
  final Color subjectColor;
  final String subjectName;

  const _AddTaskWithDeadlineModal({
    required this.date,
    required this.subjectId,
    required this.subjectColor,
    required this.subjectName,
  });

  @override
  State<_AddTaskWithDeadlineModal> createState() =>
      _AddTaskWithDeadlineModalState();
}

class _AddTaskWithDeadlineModalState extends State<_AddTaskWithDeadlineModal> {
  final _titleCtrl = TextEditingController();
  DateTime? _deadline;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.parse(widget.date);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '할 일 날짜 선택',
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '마감일 선택',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: widget.subjectColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  widget.subjectName,
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.subjectColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '할 일 추가',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: '할 일을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // 날짜 선택
            Row(
              children: [
                Expanded(
                  child: _DatePickerButton(
                    icon: Icons.calendar_today,
                    label: '날짜',
                    value: DateFormat('M월 d일').format(_selectedDate),
                    color: widget.subjectColor,
                    onTap: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DatePickerButton(
                    icon: Icons.flag_outlined,
                    label: '마감일 (선택)',
                    value: _deadline != null
                        ? DateFormat('M월 d일').format(_deadline!)
                        : '없음',
                    color: _deadline != null
                        ? const Color(0xFFFA8C16)
                        : const Color(0xFF999999),
                    onTap: _pickDeadline,
                    onClear: _deadline != null
                        ? () => setState(() => _deadline = null)
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('취소', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final title = _titleCtrl.text.trim();
                      if (title.isEmpty) return;
                      provider.addTask(
                        title,
                        widget.subjectId,
                        _dateStr(_selectedDate),
                        deadline: _deadline != null
                            ? _dateStr(_deadline!)
                            : null,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.subjectColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      '추가',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatePickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const _DatePickerButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF999999),
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(
                  Icons.close,
                  size: 14,
                  color: Color(0xFFCCCCCC),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
