import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressProvider>(
      builder: (context, progress, _) {
        return CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('My Progress'),
              pinned: true,
              automaticallyImplyLeading: false,
            ),

            // Level card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildLevelCard(progress),
              ),
            ),

            // Weekly chart
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildWeeklyChart(context, progress),
              ),
            ),

            // Category progress
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Skill Breakdown',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    ...progress.categoryProgress.entries.map(
                      (e) => _buildSkillBar(context, e.key, e.value),
                    ),
                  ],
                ),
              ),
            ),

            // Achievements preview
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: _buildAchievements(context),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildLevelCard(ProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 45,
            lineWidth: 8,
            percent: progress.levelProgress.clamp(0.0, 1.0),
            center: Text(
              '${progress.currentLevel}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            progressColor: AppTheme.accentCyan,
            backgroundColor: Colors.white.withOpacity(0.2),
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Current Level',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _getLevelTitle(progress.currentLevel),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${progress.totalXP} / ${progress.xpToNextLevel} XP to next level',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level <= 3) return 'Beginner';
    if (level <= 6) return 'Elementary';
    if (level <= 10) return 'Intermediate';
    if (level <= 15) return 'Advanced';
    return 'Master';
  }

  Widget _buildWeeklyChart(BuildContext context, ProgressProvider progress) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 50,
                barTouchData: BarTouchData(
                  enabled: true,
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      return BarTooltipItem(
                        '${days[group.x.toInt()]}\n${rod.toY.toInt()} min',
                        const TextStyle(color: Colors.white, fontSize: 12),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        return Text(
                          days[value.toInt()],
                          style: const TextStyle(fontSize: 12),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(7, (i) {
                  final minutes = progress.weeklyActivity.isNotEmpty
                      ? (progress.weeklyActivity[i]['minutes'] as int).toDouble()
                      : 0.0;
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: minutes,
                        gradient: AppTheme.coolGradient,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillBar(BuildContext context, String skill, double progress) {
    final colors = {
      'vocabulary': AppTheme.primaryBlue,
      'grammar': AppTheme.secondaryPurple,
      'pronunciation': AppTheme.accentGreen,
      'listening': AppTheme.accentOrange,
      'reading': AppTheme.accentCyan,
      'writing': AppTheme.accentPink,
      'conversation': AppTheme.primaryBlue,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                skill[0].toUpperCase() + skill.substring(1),
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  color: colors[skill] ?? AppTheme.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          LinearPercentIndicator(
            padding: EdgeInsets.zero,
            lineHeight: 8,
            percent: progress.clamp(0.0, 1.0),
            backgroundColor: (colors[skill] ?? AppTheme.primaryBlue).withOpacity(0.1),
            progressColor: colors[skill] ?? AppTheme.primaryBlue,
            barRadius: const Radius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements(BuildContext context) {
    final achievements = [
      {'emoji': '🌟', 'title': 'First Lesson', 'unlocked': true},
      {'emoji': '🔥', 'title': '7-Day Streak', 'unlocked': true},
      {'emoji': '📚', 'title': '50 Words Learned', 'unlocked': true},
      {'emoji': '🏆', 'title': 'Perfect Score', 'unlocked': false},
      {'emoji': '🎯', 'title': 'Grammar Expert', 'unlocked': false},
      {'emoji': '🗣️', 'title': 'Speaking Star', 'unlocked': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Achievements',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: achievements.map((a) {
            final unlocked = a['unlocked'] as bool;
            return Container(
              width: (MediaQuery.of(context).size.width - 64) / 3,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: unlocked
                    ? AppTheme.accentOrange.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: unlocked
                      ? AppTheme.accentOrange.withOpacity(0.3)
                      : Colors.grey.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    a['emoji'] as String,
                    style: TextStyle(
                      fontSize: 28,
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a['title'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: unlocked ? null : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
