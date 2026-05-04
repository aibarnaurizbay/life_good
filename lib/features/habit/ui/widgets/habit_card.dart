import 'package:flutter/material.dart';
import '../../data/habit_model.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onDelete,
  });

  // Последние 7 дней
  List<DateTime> _lastSevenDays() {
    final today = DateTime.now();
    return List.generate(7, (i) =>
        today.subtract(Duration(days: 6 - i)));
  }

  String _dayLabel(DateTime date) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDone = habit.isCompletedToday;
    final days = _lastSevenDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Верхняя часть — название + меню
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: isDone ? null : onComplete,
                    child: Text(
                      habit.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDone
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                        decoration: isDone
                            ? TextDecoration.none
                            : null,
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert,
                      color: theme.colorScheme.outline, size: 20),
                  onSelected: (v) {
                    if (v == 'delete') onDelete();
                    if (v == 'complete') onComplete();
                  },
                  itemBuilder: (_) => [
                    if (!isDone)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green),
                            SizedBox(width: 8),
                            Text('Выполнено'),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Подзаголовок — streak, overall, приватность
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Row(
              children: [
                _InfoChip(
                  label:
                      'Streak: +${habit.currentStreak}',
                  color: habit.currentStreak > 0
                      ? Colors.orange
                      : theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: 'Overall: ${_overallPercent()}%',
                  color: theme.colorScheme.outline,
                ),
                const SizedBox(width: 8),
                _InfoChip(
                  label: '+${habit.pointsReward}\u{2B50}',
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ),

          // Разделитель
          Divider(
            height: 1,
            color: theme.colorScheme.outlineVariant,
          ),

          // Дни недели
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isToday = _isToday(day);
                final isCompleted = isToday && isDone;

                return Column(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? theme.colorScheme.primary
                            : isToday
                                ? theme.colorScheme.primaryContainer
                                : theme.colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(Icons.check,
                                color: Colors.white, size: 18)
                            : Text(
                                _dayLabel(day),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isToday
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                      ),
                    ),
                    if (isToday)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'TODAY',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  int _overallPercent() {
    // Считаем процент выполнения на основе streak
    if (habit.longestStreak == 0) return 0;
    final ratio = habit.currentStreak / habit.longestStreak;
    return (ratio * 100).round().clamp(0, 100);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final Color color;

  const _InfoChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12,
        color: color,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}