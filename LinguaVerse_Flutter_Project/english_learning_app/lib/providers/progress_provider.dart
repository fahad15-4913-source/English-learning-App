import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Progress Provider
// ─────────────────────────────────────────────
class ProgressProvider extends ChangeNotifier {
  int _totalXP = 0;
  int _currentLevel = 1;
  int _streak = 0;
  int _gems = 50;
  int _lessonsCompleted = 0;
  int _wordsLearned = 0;
  int _minutesStudied = 0;
  List<String> _completedLessonIds = [];
  Map<String, double> _categoryProgress = {
    'vocabulary': 0.0,
    'grammar': 0.0,
    'pronunciation': 0.0,
    'listening': 0.0,
    'reading': 0.0,
    'writing': 0.0,
    'conversation': 0.0,
  };
  List<Map<String, dynamic>> _weeklyActivity = [];

  int get totalXP => _totalXP;
  int get currentLevel => _currentLevel;
  int get streak => _streak;
  int get gems => _gems;
  int get lessonsCompleted => _lessonsCompleted;
  int get wordsLearned => _wordsLearned;
  int get minutesStudied => _minutesStudied;
  List<String> get completedLessonIds => _completedLessonIds;
  Map<String, double> get categoryProgress => _categoryProgress;
  List<Map<String, dynamic>> get weeklyActivity => _weeklyActivity;

  int get xpToNextLevel => _currentLevel * 100;
  double get levelProgress => _totalXP % xpToNextLevel / xpToNextLevel;

  void addXP(int amount) {
    _totalXP += amount;
    while (_totalXP >= _currentLevel * 100) {
      _totalXP -= _currentLevel * 100;
      _currentLevel++;
    }
    notifyListeners();
  }

  void completeLesson(String lessonId, int xp, String category) {
    if (!_completedLessonIds.contains(lessonId)) {
      _completedLessonIds.add(lessonId);
      _lessonsCompleted++;
    }
    addXP(xp);
    _updateCategoryProgress(category);
    notifyListeners();
  }

  void addGems(int amount) {
    _gems += amount;
    notifyListeners();
  }

  void incrementStreak() {
    _streak++;
    notifyListeners();
  }

  void _updateCategoryProgress(String category) {
    final key = category.toLowerCase();
    if (_categoryProgress.containsKey(key)) {
      _categoryProgress[key] =
          (_categoryProgress[key]! + 0.1).clamp(0.0, 1.0);
    }
  }

  void initDemoData() {
    _totalXP = 350;
    _currentLevel = 4;
    _streak = 7;
    _gems = 120;
    _lessonsCompleted = 12;
    _wordsLearned = 85;
    _minutesStudied = 240;
    _categoryProgress = {
      'vocabulary': 0.6,
      'grammar': 0.4,
      'pronunciation': 0.3,
      'listening': 0.25,
      'reading': 0.2,
      'writing': 0.15,
      'conversation': 0.35,
    };
    _weeklyActivity = [
      {'day': 'Mon', 'minutes': 25, 'xp': 45},
      {'day': 'Tue', 'minutes': 30, 'xp': 60},
      {'day': 'Wed', 'minutes': 15, 'xp': 30},
      {'day': 'Thu', 'minutes': 40, 'xp': 75},
      {'day': 'Fri', 'minutes': 20, 'xp': 40},
      {'day': 'Sat', 'minutes': 35, 'xp': 65},
      {'day': 'Sun', 'minutes': 30, 'xp': 55},
    ];
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
// Theme Provider
// ─────────────────────────────────────────────
class AppThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
