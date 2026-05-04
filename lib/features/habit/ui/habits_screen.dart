import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/points_provider.dart';
import '../../../shared/widgets/points_header.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../data/habit_model.dart';
import '../../task/bloc/task_bloc.dart';
import '../../task/bloc/task_event.dart';
import '../../task/bloc/task_state.dart';
import '../../task/data/task_model.dart';
import '../../task/ui/widgets/task_card.dart';
import '../../task/ui/widgets/add_task_sheet.dart';
import 'widgets/habit_card.dart';
import 'widgets/add_habit_sheet.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showPoints(BuildContext context, int points,
      {int streak = 0, bool isBonus = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('\u{2B50}', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              isBonus
                  ? '+$points баллов! \u{1F525} Бонус за серию $streak дней!'
                  : '+$points баллов!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddHabit() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddHabitSheet(
        onAdd: (habit) =>
            context.read<HabitBloc>().add(AddHabitEvent(habit)),
      ),
    );
  }

  void _showAddTask() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddTaskSheet(
        onAdd: (task) =>
            context.read<TaskBloc>().add(AddTaskEvent(task)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        foregroundColor: Colors.white,
        title: const Text(
          'My Habits',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _showAddHabit();
              } else {
                _showAddTask();
              }
            },
            child: const Text(
              'Add',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Column(
            children: [
              // ALL HABITS + процент
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'ALL HABITS',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1,
                      ),
                    ),
                    BlocBuilder<HabitBloc, HabitState>(
                      builder: (context, state) {
                        List<Habit> habits = [];
                        if (state is HabitLoaded) habits = state.habits;
                        if (state is HabitCompleted) habits = state.habits;
                        if (habits.isEmpty) {
                          return const Text('0%',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold));
                        }
                        final done =
                            habits.where((h) => h.isCompletedToday).length;
                        final percent =
                            ((done / habits.length) * 100).round();
                        return Text(
                          '$percent%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              // TabBar
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(text: 'Привычки'),
                  Tab(text: 'Задачи'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          // Виджет баллов
          const PointsHeader(),

          // Контент вкладок
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _HabitsTab(
                  onPointsEarned: (ctx, pts,
                          {streak = 0, isBonus = false}) =>
                      _showPoints(ctx, pts,
                          streak: streak, isBonus: isBonus),
                ),
                _TasksTab(
                  onPointsEarned: (ctx, pts,
                          {streak = 0, isBonus = false}) =>
                      _showPoints(ctx, pts),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Вкладка Привычки
// ─────────────────────────────────────────
class _HabitsTab extends StatelessWidget {
  final void Function(BuildContext, int, {int streak, bool isBonus})
      onPointsEarned;

  const _HabitsTab({required this.onPointsEarned});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HabitBloc, HabitState>(
      listener: (context, state) {
        if (state is HabitCompleted) {
          context.read<PointsProvider>().refresh();
          onPointsEarned(
            context,
            state.pointsEarned,
            streak: state.streak,
            isBonus: state.isStreakBonus,
          );
        }
      },
      builder: (context, state) {
        if (state is HabitLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Habit> habits = [];
        if (state is HabitLoaded) habits = state.habits;
        if (state is HabitCompleted) habits = state.habits;

        if (habits.isEmpty) {
          return const _EmptyState(
            emoji: '\u{1F331}',
            title: 'Нет привычек на сегодня',
            subtitle: 'Нажми Add чтобы добавить первую привычку',
          );
        }

        final sorted = [...habits]
          ..sort((a, b) => a.isCompletedToday ? 1 : -1);

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: sorted.length,
          itemBuilder: (context, index) {
            final habit = sorted[index];
            return HabitCard(
              habit: habit,
              onComplete: () => context
                  .read<HabitBloc>()
                  .add(CompleteHabitEvent(habit.id)),
              onDelete: () => context
                  .read<HabitBloc>()
                  .add(DeleteHabitEvent(habit.id)),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Вкладка Задачи
// ─────────────────────────────────────────
class _TasksTab extends StatelessWidget {
  final void Function(BuildContext, int, {int streak, bool isBonus})
      onPointsEarned;

  const _TasksTab({required this.onPointsEarned});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listener: (context, state) {
        if (state is TaskCompleted) {
          context.read<PointsProvider>().refresh();
          onPointsEarned(context, state.pointsEarned);
        }
      },
      builder: (context, state) {
        if (state is TaskLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        List<Task> tasks = [];
        if (state is TaskLoaded) tasks = state.tasks;
        if (state is TaskCompleted) tasks = state.tasks;

        if (tasks.isEmpty) {
          return const _EmptyState(
            emoji: '\u{2705}',
            title: 'Нет активных задач',
            subtitle: 'Нажми Add чтобы добавить задачу',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 80),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            final task = tasks[index];
            return TaskCard(
              task: task,
              onComplete: () => context
                  .read<TaskBloc>()
                  .add(CompleteTaskEvent(task.id)),
              onDelete: () => context
                  .read<TaskBloc>()
                  .add(DeleteTaskEvent(task.id)),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────
// Пустой экран
// ─────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: Colors.white)),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white38,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}