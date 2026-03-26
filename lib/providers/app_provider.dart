import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/subject.dart';
import '../models/task.dart';
import '../models/event.dart';

const _uuid = Uuid();

class AppProvider extends ChangeNotifier {
  List<Subject> subjects = [];
  List<Task> tasks = [];
  List<Event> events = [];
  String lastOpenedDate = '';
  String weeklyReviewShown = '';

  List<Task> carriedOverTasks = [];
  bool showCarryOver = false;
  bool showWeeklyReview = false;
  List<Task> weeklyUncompletedTasks = [];

  Set<String> selectedSubjectIds = {};
  bool showEvents = true;
  bool isDarkMode = false;

  Future<void> init() async {
    await _load();
    final today = _todayStr();

    if (lastOpenedDate != today) {
      final yesterday = _yesterdayStr(today);
      final uncompleted = tasks
          .where((t) => t.date == yesterday && !t.completed)
          .toList();

      if (uncompleted.isNotEmpty) {
        final newTasks = uncompleted
            .map(
              (t) => t.copyWith(
                id: _uuid.v4(),
                date: today,
                carriedOver: true,
                originalDate: t.originalDate ?? t.date,
                completed: false,
              ),
            )
            .toList();
        tasks = [...tasks, ...newTasks];
        carriedOverTasks = newTasks;
        showCarryOver = true;
      }

      lastOpenedDate = today;
      await _save();
    }

    // 일요일 주간 리뷰
    final now = DateTime.now();
    if (now.weekday == DateTime.sunday && weeklyReviewShown != today) {
      final weekStart = now.subtract(const Duration(days: 6));
      final weekDays = List.generate(
        6,
        (i) => _dateStr(weekStart.add(Duration(days: i))),
      );
      final uncompleted = tasks
          .where((t) => weekDays.contains(t.date) && !t.completed)
          .toList();
      if (uncompleted.isNotEmpty) {
        weeklyUncompletedTasks = uncompleted;
        showWeeklyReview = true;
        weeklyReviewShown = today;
        await _save();
      }
    }

    notifyListeners();
  }

  void dismissCarryOver() {
    showCarryOver = false;
    notifyListeners();
  }

  void dismissWeeklyReview() {
    showWeeklyReview = false;
    notifyListeners();
  }

  // --- 과목 ---
  Future<void> addSubject(String name, Color color) async {
    subjects = [...subjects, Subject(id: _uuid.v4(), name: name, color: color)];
    await _save();
    notifyListeners();
  }

  Future<void> updateSubject(String id, String name, Color color) async {
    subjects = subjects
        .map((s) => s.id == id ? s.copyWith(name: name, color: color) : s)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> deleteSubject(String id) async {
    subjects = subjects.where((s) => s.id != id).toList();
    tasks = tasks.where((t) => t.subjectId != id).toList();
    await _save();
    notifyListeners();
  }

  // --- 할 일 ---
  Future<void> addTask(
    String title,
    String subjectId,
    String date, {
    String? deadline,
  }) async {
    tasks = [
      ...tasks,
      Task(
        id: _uuid.v4(),
        title: title,
        subjectId: subjectId,
        date: date,
        deadline: deadline,
      ),
    ];
    await _save();
    notifyListeners();
  }

  Future<void> toggleTask(String id) async {
    tasks = tasks
        .map((t) => t.id == id ? t.copyWith(completed: !t.completed) : t)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> deleteTask(String id) async {
    tasks = tasks.where((t) => t.id != id).toList();
    await _save();
    notifyListeners();
  }

  Future<void> postponeTaskToTomorrow(String id) async {
    final tomorrow = _dateStr(DateTime.now().add(const Duration(days: 1)));
    tasks = tasks
        .map((t) => t.id == id ? t.copyWith(date: tomorrow) : t)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> undoPostponeTask(String id, String originalDate) async {
    tasks = tasks
        .map((t) => t.id == id ? t.copyWith(date: originalDate) : t)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> markTaskAsYesterday(String id) async {
    final yesterday = _dateStr(
      DateTime.now().subtract(const Duration(days: 1)),
    );
    tasks = tasks
        .map(
          (t) => t.id == id ? t.copyWith(date: yesterday, completed: true) : t,
        )
        .toList();
    await _save();
    notifyListeners();
  }

  // --- 1회성 일정 ---
  Future<void> addEvent(
    String title,
    String date, {
    String? time,
    String? note,
  }) async {
    events = [
      ...events,
      Event(id: _uuid.v4(), title: title, date: date, time: time, note: note),
    ];
    await _save();
    notifyListeners();
  }

  Future<void> toggleEvent(String id) async {
    events = events
        .map((e) => e.id == id ? e.copyWith(completed: !e.completed) : e)
        .toList();
    await _save();
    notifyListeners();
  }

  Future<void> deleteEvent(String id) async {
    events = events.where((e) => e.id != id).toList();
    await _save();
    notifyListeners();
  }

  // --- 조회 ---
  List<Task> getTasksForDate(String date) {
    final targetDate = DateTime.parse(date);
    return tasks.where((t) {
      if (t.date == date) return true;

      // 마감일이 있는 경우, 원래 날짜가 지나도 마감일까지는 표시
      if (t.deadline != null && !t.completed) {
        final taskDate = DateTime.parse(t.date);
        final deadlineDate = DateTime.parse(t.deadline!);
        final today = DateTime(
          targetDate.year,
          targetDate.month,
          targetDate.day,
        );
        final taskDay = DateTime(taskDate.year, taskDate.month, taskDate.day);
        final deadlineDay = DateTime(
          deadlineDate.year,
          deadlineDate.month,
          deadlineDate.day,
        );

        // 원래 날짜 이후이고 마감일 이전이면 표시
        return today.isAfter(taskDay) &&
            !today.isAfter(deadlineDay) &&
            t.date != date;
      }

      return false;
    }).toList();
  }

  List<Event> getEventsForDate(String date) =>
      events.where((e) => e.date == date).toList();
  Subject? getSubjectById(String id) {
    try {
      return subjects.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  // --- 캘린더 표시 설정 ---
  void toggleSubjectSelection(String subjectId) {
    if (selectedSubjectIds.contains(subjectId)) {
      selectedSubjectIds.remove(subjectId);
    } else {
      selectedSubjectIds.add(subjectId);
    }
    _save();
    notifyListeners();
  }

  void toggleEventsVisibility() {
    showEvents = !showEvents;
    _save();
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    _save();
    notifyListeners();
  }

  // --- 데이터 초기화 ---
  Future<void> resetMonthlyData() async {
    tasks = [];
    events = [];
    carriedOverTasks = [];
    weeklyUncompletedTasks = [];
    lastOpenedDate = '';
    weeklyReviewShown = '';
    await _save();
    notifyListeners();
  }

  // --- 저장/로드 ---
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'subjects',
      jsonEncode(subjects.map((s) => s.toJson()).toList()),
    );
    await prefs.setString(
      'tasks',
      jsonEncode(tasks.map((t) => t.toJson()).toList()),
    );
    await prefs.setString(
      'events',
      jsonEncode(events.map((e) => e.toJson()).toList()),
    );
    await prefs.setString('lastOpenedDate', lastOpenedDate);
    await prefs.setString('weeklyReviewShown', weeklyReviewShown);
    await prefs.setString(
      'selectedSubjectIds',
      jsonEncode(selectedSubjectIds.toList()),
    );
    await prefs.setBool('showEvents', showEvents);
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final sj = prefs.getString('subjects');
    final tj = prefs.getString('tasks');
    final ej = prefs.getString('events');
    if (sj != null)
      subjects = (jsonDecode(sj) as List)
          .map((e) => Subject.fromJson(e))
          .toList();
    if (tj != null)
      tasks = (jsonDecode(tj) as List).map((e) => Task.fromJson(e)).toList();
    if (ej != null)
      events = (jsonDecode(ej) as List).map((e) => Event.fromJson(e)).toList();
    lastOpenedDate = prefs.getString('lastOpenedDate') ?? '';
    weeklyReviewShown = prefs.getString('weeklyReviewShown') ?? '';
    final ssj = prefs.getString('selectedSubjectIds');
    if (ssj != null)
      selectedSubjectIds = (jsonDecode(ssj) as List).cast<String>().toSet();
    showEvents = prefs.getBool('showEvents') ?? true;
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
  }

  static String _todayStr() => _dateStr(DateTime.now());
  static String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  static String _yesterdayStr(String today) =>
      _dateStr(DateTime.parse(today).subtract(const Duration(days: 1)));
}
