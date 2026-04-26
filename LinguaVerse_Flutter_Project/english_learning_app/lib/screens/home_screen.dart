import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../providers/progress_provider.dart';
import '../providers/learning_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/category_card.dart';
import '../widgets/streak_widget.dart';
import '../widgets/lesson_card.dart';
import 'lesson_screen.dart';
import 'progress_screen.dart';
import 'vocabulary_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  int _currentTab = 0;
  late AnimationController _fabController;

  final List<Widget> _screens = [];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Load demo data if not loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final learning = context.read<LearningProvider>();
      if (learning.allLessons.isEmpty) {
        learning.loadDemoLessons();
      }
      final progress = context.read<ProgressProvider>();
      if (progress.totalXP == 0) {
        progress.initDemoData();
      }
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      _buildDashboard(),
      const VocabularyScreen(),
      const ProgressScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentTab,
        children: screens,
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: _currentTab == 0 ? _buildFAB() : null,
    );
  }

  // ────────────────────────────────────────────
  // Dashboard Tab
  // ────────────────────────────────────────────
  Widget _buildDashboard() {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 200,
          floating: false,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _buildHeader(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            Consumer<AppThemeProvider>(
              builder: (_, theme, __) => IconButton(
                icon: Icon(
                  theme.isDark ? Icons.light_mode : Icons.dark_mode,
                  color: Colors.white,
                ),
                onPressed: theme.toggleTheme,
              ),
            ),
          ],
        ),

        // Stats Row
        SliverToBoxAdapter(
          child: Consumer<ProgressProvider>(
            builder: (_, progress, __) => _buildStatsRow(progress),
          ),
        ),

        // Streak Widget
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Consumer<ProgressProvider>(
              builder: (_, progress, __) => StreakWidget(streak: progress.streak),
            ),
          ),
        ),

        // Categories
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Learning Categories',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildCategoryGrid()),

        // Recommended Lessons
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recommended For You',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('See All'),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(child: _buildLessonsList()),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                      border: Border.all(color: Colors.white54, width: 2),
                    ),
                    child: const Center(
                      child: Text('🧑‍🎓', style: TextStyle(fontSize: 24)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, Learner!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const Text(
                        'Ready to learn?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Consumer<ProgressProvider>(
                builder: (_, progress, __) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Level ${progress.currentLevel}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${progress.totalXP} / ${progress.xpToNextLevel} XP',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      LinearPercentIndicator(
                        padding: EdgeInsets.zero,
                        lineHeight: 8,
                        percent: progress.levelProgress.clamp(0.0, 1.0),
                        backgroundColor: Colors.white.withOpacity(0.2),
                        progressColor: AppTheme.accentCyan,
                        barRadius: const Radius.circular(4),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(ProgressProvider progress) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          _buildStatChip(
            icon: Icons.local_fire_department,
            value: '${progress.streak}',
            label: 'Streak',
            color: AppTheme.accentOrange,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.diamond_outlined,
            value: '${progress.gems}',
            label: 'Gems',
            color: AppTheme.accentCyan,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.menu_book,
            value: '${progress.lessonsCompleted}',
            label: 'Lessons',
            color: AppTheme.accentGreen,
          ),
          const SizedBox(width: 12),
          _buildStatChip(
            icon: Icons.timer,
            value: '${progress.minutesStudied}m',
            label: 'Study',
            color: AppTheme.secondaryPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryGrid() {
    final categories = [
      {'name': 'Vocabulary', 'emoji': '📚', 'color': AppTheme.primaryBlue,
        'category': LessonCategory.vocabulary},
      {'name': 'Grammar', 'emoji': '📝', 'color': AppTheme.secondaryPurple,
        'category': LessonCategory.grammar},
      {'name': 'Pronunciation', 'emoji': '🗣️', 'color': AppTheme.accentGreen,
        'category': LessonCategory.pronunciation},
      {'name': 'Listening', 'emoji': '👂', 'color': AppTheme.accentOrange,
        'category': LessonCategory.listening},
      {'name': 'Reading', 'emoji': '📖', 'color': AppTheme.accentCyan,
        'category': LessonCategory.reading},
      {'name': 'Conversation', 'emoji': '💬', 'color': AppTheme.accentPink,
        'category': LessonCategory.conversation},
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return CategoryCard(
            name: cat['name'] as String,
            emoji: cat['emoji'] as String,
            color: cat['color'] as Color,
            onTap: () {
              // Could filter lessons by category
            },
          );
        },
      ),
    );
  }

  Widget _buildLessonsList() {
    return Consumer<LearningProvider>(
      builder: (context, learning, _) {
        final lessons = learning.allLessons;
        if (lessons.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Text('No lessons available yet.'),
            ),
          );
        }
        return SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: lessons.length,
            itemBuilder: (context, index) {
              return LessonCard(
                lesson: lessons[index],
                onTap: () => _startLesson(lessons[index]),
              );
            },
          ),
        );
      },
    );
  }

  void _startLesson(Lesson lesson) {
    context.read<LearningProvider>().startLesson(lesson);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonScreen(lesson: lesson),
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _fabController,
      builder: (_, __) {
        final scale = 1.0 + sin(_fabController.value * pi) * 0.05;
        return Transform.scale(
          scale: scale,
          child: FloatingActionButton.extended(
            onPressed: () {
              // Quick practice
              final learning = context.read<LearningProvider>();
              if (learning.allLessons.isNotEmpty) {
                final randomLesson = learning.allLessons[
                    Random().nextInt(learning.allLessons.length)];
                _startLesson(randomLesson);
              }
            },
            backgroundColor: AppTheme.primaryBlue,
            icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
            label: const Text(
              'Quick Practice',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      },
    );
  }

  // ────────────────────────────────────────────
  // Bottom Navigation
  // ────────────────────────────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_outlined),
              activeIcon: Icon(Icons.book),
              label: 'Vocab',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_rounded),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
