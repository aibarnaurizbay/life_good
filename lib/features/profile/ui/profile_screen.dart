import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/points_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<PointsProvider>();
    final profile = provider.profile;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Аватар и имя
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor:
                      theme.colorScheme.primaryContainer,
                  child: Text(
                    '${provider.level}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  profile?.name ?? 'Герой',
                  style: theme.textTheme.headlineSmall,
                ),
                Text(
                  'Уровень ${provider.level}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Прогресс уровня
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Прогресс уровня',
                          style: theme.textTheme.titleSmall),
                      Text(
                        '${(provider.levelProgress * 100).round()}%',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: provider.levelProgress,
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'До уровня ${provider.level + 1}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Статистика
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Достижения',
                      style: theme.textTheme.titleSmall),
                  const SizedBox(height: 12),
                  _StatRow(
                      emoji: '⭐',
                      label: 'Всего заработано',
                      value:
                          '${profile?.totalEarnedAllTime ?? 0} баллов'),
                  _StatRow(
                      emoji: '💰',
                      label: 'Текущий баланс',
                      value: '${provider.points} баллов'),
                  _StatRow(
                      emoji: '✅',
                      label: 'Задач выполнено',
                      value: '${profile?.tasksCompleted ?? 0}'),
                  _StatRow(
                      emoji: '🔥',
                      label: 'Привычек выполнено',
                      value: '${profile?.habitsCompleted ?? 0}'),
                  _StatRow(
                      emoji: '🎯',
                      label: 'Целей достигнуто',
                      value: '${profile?.goalsCompleted ?? 0}'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _StatRow({
    required this.emoji,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: theme.textTheme.bodyMedium),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}