import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
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
    if (!mounted) return;
    setState(() {
      _completedHabits = habits.where((h) => h.currentStreak > 0).length;
      _completedTasks = tasks.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<PointsProvider>().profile;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: const Text(
          'Статистика',
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Карточки статистики
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _StatCard(
                        emoji: '\u{2B50}',
                        label: 'Баллов заработано',
                        value: '${profile?.totalEarnedAllTime ?? 0}',
                        color: Colors.amber,
                      ),
                      _StatCard(
                        emoji: '\u{1F3C6}',
                        label: 'Уровень',
                        value: '${profile?.level ?? 1}',
                        color: Colors.purple,
                      ),
                      _StatCard(
                        emoji: '\u{2705}',
                        label: 'Задач выполнено',
                        value: '${profile?.tasksCompleted ?? 0}',
                        color: Colors.green,
                      ),
                      _StatCard(
                        emoji: '\u{1F525}',
                        label: 'Привычек выполнено',
                        value: '${profile?.habitsCompleted ?? 0}',
                        color: Colors.orange,
                      ),
                      _StatCard(
                        emoji: '\u{1F3AF}',
                        label: 'Целей достигнуто',
                        value: '${profile?.goalsCompleted ?? 0}',
                        color: Colors.blue,
                      ),
                      _StatCard(
                        emoji: '\u{1F4B0}',
                        label: 'Текущий баланс',
                        value: '${profile?.totalPoints ?? 0}',
                        color: const Color(0xFF4DA6FF),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // График активности
                  const Text(
                    'Активность за неделю',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: _WeeklyChart(
                      completedTasks: _completedTasks,
                      completedHabits: _completedHabits,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Прогресс уровня
                  const Text(
                    'Прогресс уровня',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Уровень ${profile?.level ?? 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Уровень ${(profile?.level ?? 1) + 1}',
                              style: const TextStyle(
                                color: Colors.white38,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: context
                                    .watch<PointsProvider>()
                                    .levelProgress,
                            backgroundColor: Colors.white12,
                            valueColor:
                                const AlwaysStoppedAnimation<Color>(
                              Color(0xFF0047AB),
                            ),
                            minHeight: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${profile?.totalEarnedAllTime ?? 0} баллов',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12),
                            ),
                            Text(
                              '${(context.watch<PointsProvider>().levelProgress * 100).round()}%',
                              style: const TextStyle(
                                color: Color(0xFF4DA6FF),
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Мотивационная фраза
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0047AB),
                          Color(0xFF1A6BB5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '\u{1F680}',
                          style: TextStyle(fontSize: 36),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _motivationText(
                              profile?.habitsCompleted ?? 0),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  String _motivationText(int habits) {
    if (habits == 0) return 'Начни свой путь к лучшей версии себя!';
    if (habits < 10) return 'Отличное начало! Продолжай в том же духе!';
    if (habits < 50) return 'Ты на верном пути! Не останавливайся!';
    if (habits < 100) return 'Невероятный прогресс! Ты настоящий герой!';
    return 'Легендарный результат! Ты вдохновляешь других!';
  }
}

// ─────────────────────────────────────────
// Карточка статистики
// ─────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// График за неделю
// ─────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final int completedTasks;
  final int completedHabits;

  const _WeeklyChart({
    required this.completedTasks,
    required this.completedHabits,
  });

  @override
  Widget build(BuildContext context) {
    final days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    final values = [3.0, 5.0, 2.0, 7.0, 4.0, 6.0, 3.0];

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 10,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) => const Color(0xFF2C2C2E),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                '${rod.toY.round()}',
                const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
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
                style: const TextStyle(
                    color: Colors.white38, fontSize: 12),
              ),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: List.generate(7, (i) {
          final isToday = i == DateTime.now().weekday - 1;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: values[i],
                color: isToday
                    ? const Color(0xFF4DA6FF)
                    : const Color(0xFF0047AB),
                width: 22,
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