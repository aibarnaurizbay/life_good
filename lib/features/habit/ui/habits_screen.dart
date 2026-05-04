import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  void _showPoints(BuildContext context, int points,
      {int streak = 0, bool isBonus = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Text('⭐', style: TextStyle(fontSize: 18)),
            const SizedBox(width: 8),
            Text(
              isBonus
                  ? '+$points баллов! 🔥 Бонус за серию $streak дней!'
                  : '+$points баллов!',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Сегодня'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Привычки'),
              Tab(text: 'Задачи'),
            ],
          ),
        ),
        body: Column(
          children: [
            const PointsHeader(),
            Expanded(
              child: TabBarView(
                children: [
                  _HabitsTab(onPointsEarned: _showPoints),
                  _TasksTab(onPointsEarned: _showPoints),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _AddFab(),
      ),
    );
  }
}

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
          return _EmptyState(
            emoji: '🌱',
            title: 'Нет привычек на сегодня',
            subtitle: 'Нажми + чтобы добавить первую привычку',
          );
        }

        // Сортируем: невыполненные сначала
        final sorted = [...habits]
          ..sort((a, b) => a.isCompletedToday ? 1 : -1);

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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
          return _EmptyState(
            emoji: '✅',
            title: 'Нет активных задач',
            subtitle: 'Нажми + чтобы добавить задачу',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
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

class _AddFab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        final tabIndex = DefaultTabController.of(context).index;
        if (tabIndex == 0) {
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
        } else {
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
      },
      child: const Icon(Icons.add),
    );
  }
}

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
          ),
        ],
      ),
    );
  }
}