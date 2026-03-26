import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/calendar_screen.dart';
import 'screens/subjects_screen.dart';
import 'screens/weekly_summary_screen.dart';
import 'screens/settings_screen.dart';
import 'widgets/carry_over_dialog.dart';
import 'widgets/weekly_review_dialog.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.watch<AppProvider>().isDarkMode;

    return MaterialApp(
      title: '계획',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4A90D9),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        useMaterial3: true,
      ),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final _screens = const [
    CalendarScreen(),
    WeeklySummaryScreen(),
    SubjectsScreen(),
    SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initApp());
  }

  Future<void> _initApp() async {
    final provider = context.read<AppProvider>();
    await provider.init();

    if (!mounted) return;

    if (provider.showCarryOver) {
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => CarryOverDialog(
          tasks: provider.carriedOverTasks,
          onClose: () {
            provider.dismissCarryOver();
            Navigator.pop(context);
          },
        ),
      );
    }

    if (!mounted) return;

    if (provider.showWeeklyReview) {
      await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        isDismissible: false,
        builder: (_) => WeeklyReviewDialog(
          tasks: provider.weeklyUncompletedTasks,
          onClose: () {
            provider.dismissWeeklyReview();
            Navigator.pop(context);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppProvider>();
    final isDark = provider.isDarkMode;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      floatingActionButton: FloatingActionButton(
        onPressed: () => provider.toggleTheme(),
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        foregroundColor: const Color(0xFF4A90D9),
        elevation: 8,
        child: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        selectedItemColor: const Color(0xFF4A90D9),
        unselectedItemColor: isDark ? Colors.white38 : const Color(0xFFAAAAAA),
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month),
            label: '캘린더',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.assessment), label: '주간 요약'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '과목'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: '설정'),
        ],
      ),
    );
  }
}
