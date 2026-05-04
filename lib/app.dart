import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router.dart';
import 'core/theme.dart';
import 'features/habit/bloc/habit_bloc.dart';
import 'features/habit/bloc/habit_event.dart';
import 'features/task/bloc/task_bloc.dart';
import 'features/task/bloc/task_event.dart';
import 'features/goal/bloc/goal_bloc.dart';
import 'features/goal/bloc/goal_event.dart';
import 'features/shop/bloc/shop_bloc.dart';
import 'features/shop/bloc/shop_event.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HabitBloc()..add(LoadHabitsEvent()),
        ),
        BlocProvider(
          create: (_) => TaskBloc()..add(LoadTasksEvent()),
        ),
        BlocProvider(
          create: (_) => GoalBloc()..add(LoadGoalsEvent()),
        ),
        BlocProvider(
          create: (_) => ShopBloc()..add(LoadRewardsEvent()),
        ),
      ],
      child: MaterialApp.router(
        title: 'Productivity Tracker',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}