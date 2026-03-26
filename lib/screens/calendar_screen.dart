import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';
import '../models/task.dart';
import '../models/event.dart';
import '../widgets/add_task_modal.dart';
import '../widgets/add_event_modal.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _formatSelectedDate(DateTime d) {
    final days = ['일', '월', '화', '수', '목', '금', '토'];
    final isToday = isSameDay(d, DateTime.now());
    final label = isToday ? ' (오늘)' : '';
    return '${DateFormat('M월 d일').format(d)} (${days[d.weekday % 7]})$label';
  }

  void _showAddMenu(BuildContext context) {
    final dateStr = _dateStr(_selectedDay);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '무엇을 추가할까요?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _AddTypeButton(
                    icon: Icons.menu_book,
                    label: '공부 할 일',
                    color: const Color(0xFF4A90D9),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddTaskModal(date: dateStr),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _AddTypeButton(
                    icon: Icons.event,
                    label: '1회성 일정',
                    color: const Color(0xFF722ED1),
                    onTap: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => AddEventModal(date: dateStr),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showCalendarFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _CalendarFilterModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    final selectedDateStr = _dateStr(_selectedDay);
    final tasks = provider.getTasksForDate(selectedDateStr);
    final events = provider.getEventsForDate(selectedDateStr);
    final completedTasks = tasks.where((t) => t.completed).length;

    // 캘린더 마커 데이터
    Map<DateTime, List<dynamic>> calendarEvents = {};
    for (final task in provider.tasks) {
      try {
        final key = DateTime.parse(task.date);
        final norm = DateTime(key.year, key.month, key.day);
        calendarEvents[norm] = [...(calendarEvents[norm] ?? []), task];
      } catch (_) {}
    }
    for (final event in provider.events) {
      try {
        final key = DateTime.parse(event.date);
        final norm = DateTime(key.year, key.month, key.day);
        calendarEvents[norm] = [...(calendarEvents[norm] ?? []), event];
      } catch (_) {}
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '계획',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
            color: textColor,
          ),
        ),
        backgroundColor: cardColor,
        foregroundColor: textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showCalendarFilter(context),
            tooltip: '캘린더 표시 설정',
          ),
        ],
      ),
      body: Column(
        children: [
          // 캘린더
          Container(
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: (day) {
                final key = DateTime(day.year, day.month, day.day);
                return calendarEvents[key] ?? [];
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  _selectedDay = selected;
                  _focusedDay = focused;
                });
              },
              onPageChanged: (focused) => setState(() => _focusedDay = focused),
              calendarFormat: CalendarFormat.month,
              availableCalendarFormats: const {CalendarFormat.month: '월'},
              calendarStyle: CalendarStyle(
                todayDecoration: const BoxDecoration(
                  color: Color(0xFF4A90D9),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: Color(0xFF4A90D9),
                  fontWeight: FontWeight.w700,
                ),
                markerDecoration: const BoxDecoration(
                  color: Color(0xFF4A90D9),
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 4,
                outsideDaysVisible: false,
                defaultTextStyle: TextStyle(color: textColor),
                weekendTextStyle: TextStyle(color: textColor),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(color: Colors.red.shade700),
                weekdayStyle: TextStyle(color: textColor),
                dowTextFormatter: (date, locale) {
                  final days = ['일', '월', '화', '수', '목', '금', '토'];
                  return days[date.weekday % 7];
                },
              ),
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: textColor,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: textColor),
                rightChevronIcon: Icon(Icons.chevron_right, color: textColor),
              ),
              calendarBuilders: CalendarBuilders(
                defaultBuilder: (context, day, focusedDay) {
                  final text = '${day.day}';
                  Color dayTextColor = isDark
                      ? Colors.white
                      : const Color(0xFF333333);

                  // 토요일(6) - 파란색, 일요일(7) - 빨간색
                  if (day.weekday == DateTime.saturday) {
                    dayTextColor = const Color(0xFF4A90D9);
                  } else if (day.weekday == DateTime.sunday) {
                    dayTextColor = Colors.red.shade700;
                  }

                  return Center(
                    child: Text(text, style: TextStyle(color: dayTextColor)),
                  );
                },
                markerBuilder: (context, day, _) {
                  final key = DateTime(day.year, day.month, day.day);
                  final dayItems = calendarEvents[key] ?? [];
                  if (dayItems.isEmpty) return null;

                  final List<Color> colors = [];

                  // 선택된 과목의 색상만 추가
                  final selectedSubjectIdsInDay = dayItems
                      .whereType<Task>()
                      .map((t) => t.subjectId)
                      .where((sid) => provider.selectedSubjectIds.contains(sid))
                      .toSet();

                  for (final sid in selectedSubjectIdsInDay) {
                    if (colors.length >= 4) break;
                    final subject = provider.getSubjectById(sid);
                    if (subject != null) colors.add(subject.color);
                  }

                  // 1회성 일정이 있고 표시 설정이 켜져 있으면 색상 추가
                  final hasEvent = dayItems.any((item) => item is Event);
                  if (hasEvent && provider.showEvents && colors.length < 4) {
                    colors.add(const Color(0xFF722ED1));
                  }

                  if (colors.isEmpty) return null;

                  return Positioned(
                    bottom: 2,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: colors
                          .map(
                            (color) => Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),

          // 선택된 날짜 헤더
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Text(
                  _formatSelectedDate(_selectedDay),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                if (tasks.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$completedTasks/${tasks.length} 완료',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF4A90D9),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (tasks.isNotEmpty)
            LinearProgressIndicator(
              value: tasks.isEmpty ? 0 : completedTasks / tasks.length,
              backgroundColor: const Color(0xFFE0E0E0),
              color: const Color(0xFF52C41A),
              minHeight: 3,
            ),

          // 할 일 + 일정 목록
          Expanded(
            child: (tasks.isEmpty && events.isEmpty)
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_note,
                          size: 56,
                          color: (isDark ? Colors.white : Colors.grey)
                              .withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '이 날의 일정이 없어요',
                          style: TextStyle(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white60
                                : const Color(0xFF999999),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '+ 버튼으로 추가해보세요',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? Colors.white38
                                : const Color(0xFFBBBBBB),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 공부 할 일
                      if (tasks.isNotEmpty) ...[
                        const _SectionLabel(
                          icon: Icons.menu_book,
                          label: '공부 할 일',
                          color: Color(0xFF4A90D9),
                        ),
                        const SizedBox(height: 8),
                        ...tasks.map(
                          (task) => _TaskCard(
                            task: task,
                            currentDate: selectedDateStr,
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      // 1회성 일정
                      if (events.isNotEmpty) ...[
                        const _SectionLabel(
                          icon: Icons.event,
                          label: '일정',
                          color: Color(0xFF722ED1),
                        ),
                        const SizedBox(height: 8),
                        ...events.map(
                          (event) => _EventCard(
                            event: event,
                            isDark: isDark,
                            cardColor: cardColor,
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddMenu(context),
        backgroundColor: const Color(0xFF4A90D9),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _SectionLabel({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final String currentDate;
  final bool isDark;
  final Color cardColor;
  const _TaskCard({
    required this.task,
    required this.currentDate,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();
    final subject = provider.getSubjectById(task.subjectId);

    return Dismissible(
      key: Key(task.id),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // 오른쪽으로 스와이프 - 내일로 미루기
          final originalDate = task.date;
          await provider.postponeTaskToTomorrow(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('내일로 미뤘습니다'),
              duration: const Duration(seconds: 2),
              action: SnackBarAction(
                label: '취소',
                onPressed: () =>
                    provider.undoPostponeTask(task.id, originalDate),
              ),
            ),
          );
          return false;
        } else if (direction == DismissDirection.endToStart) {
          // 왼쪽으로 스와이프 - 어제 했다고 표시
          await provider.markTaskAsYesterday(task.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('어제 완료로 표시했습니다'),
              duration: Duration(seconds: 2),
            ),
          );
          return false;
        }
        return false;
      },
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF4A90D9),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.arrow_forward, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              '내일로',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF52C41A),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text(
              '어제 완료',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      child: Opacity(
        opacity: task.completed ? 0.5 : 1.0,
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: task.completed
                ? (isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9))
                : cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: task.completed
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(
                        alpha: isDark ? 0.3 : 0.05,
                      ),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: ListTile(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: subject.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                              fontSize: 12,
                              color: subject.color,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (task.carriedOver && task.originalDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3CD),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${DateFormat('M/d').format(DateTime.parse(task.originalDate!))}에서 이월',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF856404),
                        ),
                      ),
                    ),
                  if (task.deadline != null)
                    _DeadlineBadge(
                      deadline: task.deadline!,
                      taskDate: task.date,
                      currentDate: currentDate,
                    ),
                ],
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Color(0xFF4A90D9),
                  ),
                  onPressed: () {
                    final originalDate = task.date;
                    provider.postponeTaskToTomorrow(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('내일로 미뤘습니다'),
                        duration: const Duration(seconds: 2),
                        action: SnackBarAction(
                          label: '취소',
                          onPressed: () =>
                              provider.undoPostponeTask(task.id, originalDate),
                        ),
                      ),
                    );
                  },
                  tooltip: '내일로 미루기',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: Color(0xFF52C41A),
                  ),
                  onPressed: () {
                    provider.markTaskAsYesterday(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('어제 완료로 표시했습니다'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  tooltip: '어제 완료',
                ),
                IconButton(
                  icon: const Icon(
                    Icons.close,
                    size: 18,
                    color: Color(0xFFCCCCCC),
                  ),
                  onPressed: () => provider.deleteTask(task.id),
                  tooltip: '삭제',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final Event event;
  final bool isDark;
  final Color cardColor;
  const _EventCard({
    required this.event,
    required this.isDark,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppProvider>();

    return Opacity(
      opacity: event.completed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: event.completed
              ? (isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF9F9F9))
              : cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFF722ED1).withValues(alpha: 0.2),
          ),
          boxShadow: event.completed
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: GestureDetector(
            onTap: () => provider.toggleEvent(event.id),
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: event.completed
                    ? const Color(0xFF722ED1)
                    : Colors.transparent,
                border: Border.all(
                  color: event.completed
                      ? const Color(0xFF722ED1)
                      : const Color(0xFF722ED1).withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
              child: event.completed
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ),
          title: Text(
            event.title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: event.completed
                  ? const Color(0xFF999999)
                  : (isDark ? Colors.white : const Color(0xFF333333)),
              decoration: event.completed ? TextDecoration.lineThrough : null,
              decorationColor: const Color(0xFF999999),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (event.time != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Color(0xFF722ED1),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        event.time!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF722ED1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              if (event.note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Text(
                    event.note!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF999999),
                    ),
                  ),
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close, size: 18, color: Color(0xFFCCCCCC)),
            onPressed: () => provider.deleteEvent(event.id),
          ),
        ),
      ),
    );
  }
}

class _DeadlineBadge extends StatelessWidget {
  final String deadline;
  final String taskDate;
  final String currentDate;
  const _DeadlineBadge({
    required this.deadline,
    required this.taskDate,
    required this.currentDate,
  });

  @override
  Widget build(BuildContext context) {
    final d = DateTime.parse(deadline);
    final viewingDate = DateTime.parse(currentDate);
    final taskDay = DateTime.parse(taskDate);
    final today = DateTime.now();

    // 할 일 날짜 기준으로 마감일까지 남은 일수 계산
    final diff = d
        .difference(DateTime(taskDay.year, taskDay.month, taskDay.day))
        .inDays;

    // 오늘 기준으로 마감일까지 남은 일수 (초과 체크용)
    final diffFromToday = d
        .difference(DateTime(today.year, today.month, today.day))
        .inDays;

    // 마감일 당일을 보고 있는지 확인
    final isViewingDeadlineDate =
        DateTime(d.year, d.month, d.day) ==
        DateTime(viewingDate.year, viewingDate.month, viewingDate.day);

    final Color color;
    final String label;
    final IconData icon;

    if (isViewingDeadlineDate) {
      // 마감일 당일을 보고 있을 때
      color = const Color(0xFFFF4D4F);
      label = '마감일';
      icon = Icons.flag;
    } else if (diffFromToday < 0) {
      // 오늘 기준으로 마감일이 지났으면 초과 표시
      color = const Color(0xFFFF4D4F);
      label = '${diffFromToday.abs()}일 초과';
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
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _AddTypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarFilterModal extends StatelessWidget {
  const _CalendarFilterModal();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            '캘린더 표시 설정',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '선택한 과목과 일정만 캘린더에 색상으로 표시됩니다 (최대 4개)',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white60 : const Color(0xFF999999),
            ),
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            value: provider.showEvents,
            onChanged: (_) => provider.toggleEventsVisibility(),
            title: Text(
              '1회성 일정 표시',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
            subtitle: Text(
              '캘린더에 보라색 점으로 표시',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white60 : const Color(0xFF999999),
              ),
            ),
            activeThumbColor: const Color(0xFF722ED1),
            contentPadding: EdgeInsets.zero,
          ),
          Divider(
            height: 24,
            color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
          ),
          Text(
            '과목 선택',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          if (provider.subjects.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  '과목이 없습니다',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white60 : const Color(0xFF999999),
                  ),
                ),
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: provider.subjects.length,
                itemBuilder: (context, index) {
                  final subject = provider.subjects[index];
                  final isSelected = provider.selectedSubjectIds.contains(
                    subject.id,
                  );

                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) =>
                        provider.toggleSubjectSelection(subject.id),
                    title: Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: subject.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          subject.name,
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                      ],
                    ),
                    activeColor: subject.color,
                    checkColor: Colors.white,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
