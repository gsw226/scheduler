import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F5F5);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          '설정',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 테마 설정 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '테마',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
          ),
          GlassCard(
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: isDark,
              onChanged: (_) => provider.toggleTheme(),
              title: Text(
                '다크 모드',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
              subtitle: Text(
                isDark ? '어두운 테마 사용 중' : '밝은 테마 사용 중',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white60 : const Color(0xFF999999),
                ),
              ),
              secondary: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF4A90D9),
                  size: 24,
                ),
              ),
              activeThumbColor: const Color(0xFF4A90D9),
            ),
          ),
          const SizedBox(height: 24),

          // 데이터 관리 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '데이터 관리',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
          ),
          GlassCard(
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4D4F).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_sweep,
                      color: Color(0xFFFF4D4F),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    '월간 데이터 초기화',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    '할 일과 일정을 모두 삭제합니다 (과목은 유지)',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF999999),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: isDark ? Colors.white30 : const Color(0xFFCCCCCC),
                  ),
                  onTap: () => _showResetConfirmation(context, provider),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 앱 정보 섹션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Text(
              '앱 정보',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white70 : const Color(0xFF666666),
              ),
            ),
          ),
          GlassCard(
            isDark: isDark,
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: Color(0xFF4A90D9),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    '버전',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    '1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF999999),
                    ),
                  ),
                ),
                Divider(height: 1, color: isDark ? Colors.white12 : null),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_month,
                      color: Color(0xFF4A90D9),
                      size: 24,
                    ),
                  ),
                  title: Text(
                    '계획 관리 앱',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  subtitle: Text(
                    '할 일과 일정을 효율적으로 관리하세요',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.white60 : const Color(0xFF999999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // 안내 메시지
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF4A90D9).withValues(alpha: 0.3)
                    : const Color(0xFFFFAD14).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: Color(0xFFFA8C16), size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '데이터 초기화 안내',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF856404),
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '데이터는 수동으로 초기화하기 전까지 계속 누적됩니다. 한 달마다 또는 필요할 때 초기화하여 새로운 시작을 할 수 있습니다.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF856404),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, AppProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_rounded, color: Color(0xFFFF4D4F), size: 28),
            SizedBox(width: 12),
            Text('데이터 초기화'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '정말로 모든 할 일과 일정을 삭제하시겠습니까?',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F0),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        size: 16,
                        color: Color(0xFFFF4D4F),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '삭제되는 항목:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFFF4D4F),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• 모든 할 일',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  Text(
                    '• 모든 일정',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: Color(0xFF52C41A),
                      ),
                      SizedBox(width: 6),
                      Text(
                        '유지되는 항목:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF52C41A),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Text(
                    '• 과목 정보',
                    style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 작업은 되돌릴 수 없습니다.',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFFFF4D4F),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(fontSize: 15)),
          ),
          ElevatedButton(
            onPressed: () async {
              await provider.resetMonthlyData();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('데이터가 초기화되었습니다'),
                    backgroundColor: Color(0xFF52C41A),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4F),
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text(
              '초기화',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
