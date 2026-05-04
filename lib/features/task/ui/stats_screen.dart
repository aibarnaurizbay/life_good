import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../shared/points_provider.dart';
import '../../habit/data/habit_repository.dart';
import '../../task/data/task_repository.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final _habitRepo = HabitRepository();
  final _taskRepo = TaskRepository();
  int _completedHabits = 0;
  int _completedTasks = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final habits = await _habitRepo.getAll();
    final tasks = await _taskRepo.getCompleted();
    setState(() {
      _completedHabits =
          habits.where((h) => h.currentStreak > 0).length;
      _completedTasks = tasks.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = context.watch<PointsProvider>().profile;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary cards
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _StatCard(
                emoji: '⭐',
                label: 'Баллов заработано',
                value: '${profile?.totalEarnedAllTime ?? 0}',
                color: Colors.amber,
              ),
              _StatCard(
                emoji: '🏆',
                label: 'Уровень',
                value: '${profile?.level ?? 1}',
                color: Colors.purple,
              ),
              _StatCard(
                emoji: '✅',
                label: 'Задач выполнено',
                value: '${profile?.tasksCompleted ?? 0}',
                color: Colors.green,
              ),
              _StatCard(
                emoji: '🔥',
                label: 'Привычек выполнено',
                value: '${profile?.habitsCompleted ?? 0}',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text('Активность за неделю',
              style: theme.textTheme.titleMedium),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: _WeeklyChart(
              tasksCompleted: _completedTasks,
              habitsCompleted: _completedHabits,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.emoji,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold, color: color)),
              Text(label,
                  style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.outline)),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeeklyChart extends StatelessWidget {
  final int tasksCompleted;
  final int habitsCompleted;

  const _WeeklyChart({
    required this.tasksCompleted,
    required this.habitsCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    // Заглушка — в реальном приложении загружать из БД по датам
    final values = [3.0, 5.0, 2.0, 7.0, 4.0, 6.0, 3.0];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                days[value.toInt()],
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) {
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: Theme.of(context).colorScheme.primary,
                width: 20,
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(6)),
              ),
            ],
          );
        }),
      ),
    );
  }
}