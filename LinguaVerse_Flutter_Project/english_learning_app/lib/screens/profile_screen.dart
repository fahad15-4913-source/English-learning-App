import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/progress_provider.dart';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          title: const Text('Profile'),
          pinned: true,
          automaticallyImplyLeading: false,
        ),

        SliverToBoxAdapter(
          child: Consumer<ProgressProvider>(
            builder: (_, progress, __) {
              return Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.primaryGradient,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryBlue.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🧑‍🎓', style: TextStyle(fontSize: 44)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'English Learner',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Level ${progress.currentLevel} · ${_getLevelTitle(progress.currentLevel)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats grid
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildProfileStat(context, '${progress.lessonsCompleted}',
                            'Lessons', Icons.menu_book, AppTheme.primaryBlue),
                        const SizedBox(width: 12),
                        _buildProfileStat(context, '${progress.wordsLearned}',
                            'Words', Icons.abc, AppTheme.accentGreen),
                        const SizedBox(width: 12),
                        _buildProfileStat(context, '${progress.streak}',
                            'Streak', Icons.local_fire_department, AppTheme.accentOrange),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Settings
                  _buildSettingsSection(context),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  String _getLevelTitle(int level) {
    if (level <= 3) return 'Beginner';
    if (level <= 6) return 'Elementary';
    if (level <= 10) return 'Intermediate';
    if (level <= 15) return 'Advanced';
    return 'Master';
  }

  Widget _buildProfileStat(BuildContext context, String value, String label,
      IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          // Dark mode
          Consumer<AppThemeProvider>(
            builder: (_, theme, __) => _buildSettingsTile(
              context,
              icon: Icons.dark_mode,
              title: 'Dark Mode',
              trailing: Switch(
                value: theme.isDark,
                onChanged: (_) => theme.toggleTheme(),
                activeColor: AppTheme.primaryBlue,
              ),
            ),
          ),

          _buildSettingsTile(context,
              icon: Icons.volume_up, title: 'Sound Effects',
              trailing: Switch(value: true, onChanged: (_) {},
                  activeColor: AppTheme.primaryBlue)),

          _buildSettingsTile(context,
              icon: Icons.notifications, title: 'Notifications',
              trailing: Switch(value: true, onChanged: (_) {},
                  activeColor: AppTheme.primaryBlue)),

          _buildSettingsTile(context,
              icon: Icons.language, title: 'Native Language',
              trailing: const Text('Auto-detect')),

          _buildSettingsTile(context,
              icon: Icons.flag, title: 'Daily Goal',
              trailing: const Text('15 min/day')),

          const SizedBox(height: 24),

          // About
          Text(
            'About',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),

          _buildSettingsTile(context,
              icon: Icons.info_outline, title: 'About LinguaVerse'),
          _buildSettingsTile(context,
              icon: Icons.privacy_tip_outlined, title: 'Privacy Policy'),
          _buildSettingsTile(context,
              icon: Icons.description_outlined, title: 'Terms of Service'),

          const SizedBox(height: 24),

          // Sign out
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout, color: AppTheme.errorRed),
              label: const Text('Sign Out',
                  style: TextStyle(color: AppTheme.errorRed)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.errorRed),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context,
      {required IconData icon, required String title, Widget? trailing}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.primaryBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
    );
  }
}
