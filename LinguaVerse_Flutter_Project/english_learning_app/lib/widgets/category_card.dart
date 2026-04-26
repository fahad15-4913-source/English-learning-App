import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

// ─────────────────────────────────────────────
// Category Card
// ─────────────────────────────────────────────
class CategoryCard extends StatelessWidget {
  final String name;
  final String emoji;
  final Color color;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    required this.emoji,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Streak Widget
// ─────────────────────────────────────────────
class StreakWidget extends StatelessWidget {
  final int streak;

  const StreakWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final today = DateTime.now().weekday - 1; // 0 = Monday

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentOrange.withOpacity(0.1),
            AppTheme.accentOrange.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentOrange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Streak fire icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🔥', style: TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),

          // Streak count
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak day streak!',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.accentOrange,
                ),
              ),
              const Text(
                'Keep it going!',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          const Spacer(),

          // Day dots
          Row(
            children: List.generate(7, (i) {
              final isActive = i <= today && i >= today - (streak - 1).clamp(0, 6);
              return Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? AppTheme.accentOrange
                      : AppTheme.accentOrange.withOpacity(0.15),
                ),
                child: Center(
                  child: Text(
                    days[i],
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.white : AppTheme.accentOrange,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Lesson Card
// ─────────────────────────────────────────────
class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonCard({
    super.key,
    required this.lesson,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final categoryColors = {
      LessonCategory.vocabulary: AppTheme.primaryBlue,
      LessonCategory.grammar: AppTheme.secondaryPurple,
      LessonCategory.pronunciation: AppTheme.accentGreen,
      LessonCategory.listening: AppTheme.accentOrange,
      LessonCategory.reading: AppTheme.accentCyan,
      LessonCategory.writing: AppTheme.accentPink,
      LessonCategory.conversation: AppTheme.primaryBlue,
    };

    final color = categoryColors[lesson.category] ?? AppTheme.primaryBlue;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 240,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.15)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      lesson.iconEmoji,
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${lesson.xpReward} XP',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              lesson.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              lesson.description,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Icon(Icons.timer_outlined, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${lesson.estimatedMinutes} min',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
                const SizedBox(width: 12),
                Icon(Icons.layers_outlined, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 4),
                Text(
                  '${lesson.steps.length} steps',
                  style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
