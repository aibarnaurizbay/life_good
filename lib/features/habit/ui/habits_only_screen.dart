import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/points_provider.dart';
import '../../../shared/widgets/points_header.dart';
import '../bloc/habit_bloc.dart';
import '../bloc/habit_event.dart';
import '../bloc/habit_state.dart';
import '../data/habit_model.dart';
import 'widgets/habit_card.dart';
import 'widgets/add_habit_sheet.dart';

class HabitsOnlyScreen extends StatelessWidget {
  const HabitsOnlyScreen({super.key});

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
                  ? '+$points баллов! \u{1F525} Бонус $streak дней!'
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

  void _showAddHabit(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddHabitSheet(
        onAdd: (habit) =>
            context.read<HabitBloc>().add(AddHabitEvent(habit)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: const Text(
          'Привычки',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
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
        ),
      ),
      body: Column(
        children: [
          const PointsHeader(),
          Expanded(
            child: BlocConsumer<HabitBloc, HabitState>(
              listener: (context, state) {
                if (state is HabitCompleted) {
                  context.read<PointsProvider>().refresh();
                  _showPoints(
                    context,
                    state.pointsEarned,
                    streak: state.streak,
                    isBonus: state.isStreakBonus,
                  );
                }
              },
              builder: (context, state) {
                if (state is HabitLoading) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                List<Habit> habits = [];
                if (state is HabitLoaded) habits = state.habits;
                if (state is HabitCompleted) habits = state.habits;

                if (habits.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('\u{1F331}',
                            style: TextStyle(fontSize: 56)),
                        const SizedBox(height: 16),
                        const Text(
                          'Нет привычек на сегодня',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Нажми + чтобы добавить первую привычку',
                          style: TextStyle(
                              color: Colors.white38, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                final sorted = [...habits]
                  ..sort((a, b) => a.isCompletedToday ? 1 : -1);

                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 100),
                  itemCount: sorted.length,
                  itemBuilder: (context, index) {
                    final habit = sorted[index];
                    return HabitCard(
                      habit: habit,
                      onComplete: () => context
                          .read<HabitBloc>()
                          .add(CompleteHabitEvent(habit.id)),
                      onCancel: () => context
                          .read<HabitBloc>()
                          .add(CancelHabitEvent(habit.id)),
                      onDelete: () => context
                          .read<HabitBloc>()
                          .add(DeleteHabitEvent(habit.id)),
                      onEdit: (title, points) {
                        habit.title = title;
                        habit.pointsReward = points;
                        context
                            .read<HabitBloc>()
                            .add(UpdateHabitEvent(habit));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0047AB),
        onPressed: () => _showAddHabit(context),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}