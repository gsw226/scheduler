import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_provider.dart';

class AddTaskModal extends StatefulWidget {
  final String date;
  const AddTaskModal({super.key, required this.date});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final _titleCtrl = TextEditingController();
  String? _selectedSubjectId;
  DateTime? _deadline;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: '마감일 선택',
    );
    if (picked != null) setState(() => _deadline = picked);
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  color: isDark ? Colors.white24 : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '할 일 추가',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: textColor,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              autofocus: true,
              maxLength: 100,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: '오늘 할 일을 입력하세요',
                hintStyle: TextStyle(
                  color: isDark ? Colors.white38 : const Color(0xFF999999),
                ),
                filled: true,
                fillColor: isDark
                    ? const Color(0xFF2C2C2E)
                    : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '과목 선택',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Color(0xFF666666),
              ),
            ),
            const SizedBox(height: 12),
            if (provider.subjects.isEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  '과목 탭에서 먼저 과목을 추가해주세요',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : Color(0xFF999999),
                  ),
                ),
              )
            else
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: provider.subjects
                      .map(
                        (subject) => GestureDetector(
                          onTap: () =>
                              setState(() => _selectedSubjectId = subject.id),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, bottom: 16),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _selectedSubjectId == subject.id
                                  ? subject.color
                                  : Colors.transparent,
                              border: Border.all(
                                color: subject.color,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              subject.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _selectedSubjectId == subject.id
                                    ? Colors.white
                                    : subject.color,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            // 마감일 선택
            GestureDetector(
              onTap: _pickDeadline,
              child: Container(
                margin: const EdgeInsets.only(bottom: 20),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: _deadline != null
                        ? const Color(0xFFFA8C16)
                        : const Color(0xFFE0E0E0),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.flag_outlined,
                      size: 18,
                      color: _deadline != null
                          ? const Color(0xFFFA8C16)
                          : const Color(0xFF999999),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _deadline != null
                          ? '마감일: ${DateFormat('yyyy년 M월 d일').format(_deadline!)}'
                          : '마감일 설정 (선택)',
                      style: TextStyle(
                        fontSize: 14,
                        color: _deadline != null
                            ? const Color(0xFFFA8C16)
                            : const Color(0xFF999999),
                        fontWeight: _deadline != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    const Spacer(),
                    if (_deadline != null)
                      GestureDetector(
                        onTap: () => setState(() => _deadline = null),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFFCCCCCC),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
                      if (title.isEmpty || _selectedSubjectId == null) return;
                      provider.addTask(
                        title,
                        _selectedSubjectId!,
                        widget.date,
                        deadline: _deadline != null
                            ? _dateStr(_deadline!)
                            : null,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A90D9),
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
