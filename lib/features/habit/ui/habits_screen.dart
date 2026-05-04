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

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  void _showPoints(
    BuildContext context,
    int points, {
    int streak = 0,
    bool isBonus = false,
  }) {
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
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAddHabit(BuildContext context) {
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

  void _showAddTask(BuildContext context) {
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            // Шапка в стиле скриншота
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xFF1A7A7A),
              foregroundColor: Colors.white,
              expandedHeight: 0,
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
                Builder(
                  builder: (ctx) => TextButton(
                    onPressed: () {
                      final tabIndex =
                          DefaultTabController.of(ctx).index;
                      if (tabIndex == 0) {
                        _showAddHabit(context);
                      } else {
                        _showAddTask(context);
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
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Column(
                  children: [
                    // Строка ALL HABITS + процент
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween,
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
                              if (state is HabitLoaded) {
                                habits = state.habits;
                              }
                              if (state is HabitCompleted) {
                                habits = state.habits;
                              }
                              if (habits.isEmpty) {
                                return const Text(
                                  '0%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                              final done = habits
                                  .where((h) => h.isCompletedToday)
                                  .length;
                              final percent =
                                  ((done / habits.length) * 100)
                                      .round();
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
                    const TabBar(
                      indicatorColor: Colors.white,
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.white60,
                      tabs: [
                        Tab(text: 'Привычки'),
                        Tab(text: 'Задачи'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Виджет баллов
            SliverToBoxAdapter(
              child: const PointsHeader(),
            ),
          ],
          body: TabBarView(
            children: [
              _HabitsTab(onPointsEarned: _showPoints),
              _TasksTab(onPointsEarned: _showPoints),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Вкладка Привычки
// ─────────────────────────────────────────
class _HabitsTab extends StatelessWidget {
  final void Function(
    BuildContext,
    int, {
    int streak,
    bool isBonus,
  }) onPointsEarned;

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
          return _EmptyState(
            emoji: '\u{1F331}',
            title: 'Нет привычек на сегодня',
            subtitle: 'Нажми Add чтобы добавить первую привычку',
          );
        }

        // Невыполненные сначала
        final sorted = [...habits]
          ..sort((a, b) =>
              a.isCompletedToday ? 1 : -1);

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
  final void Function(
    BuildContext,
    int, {
    int streak,
    bool isBonus,
  }) onPointsEarned;

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
          return _EmptyState(
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
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}