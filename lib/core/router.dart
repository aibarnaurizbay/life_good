import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../features/habit/ui/habits_screen.dart';
import '../features/goal/ui/goals_screen.dart';
import '../features/shop/ui/shop_screen.dart';
import '../features/stats/ui/stats_screen.dart';
import '../features/profile/ui/profile_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: false,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _ScaffoldWithNavBar(child: child),
      routes: [
        GoRoute(
          path: '/',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: HabitsScreen()),
        ),
        GoRoute(
          path: '/goals',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: GoalsScreen()),
        ),
        GoRoute(
          path: '/shop',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ShopScreen()),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: StatsScreen()),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ProfileScreen()),
        ),
      ],
    ),
  ],
);

class _ScaffoldWithNavBar extends StatelessWidget {
  final Widget child;
  const _ScaffoldWithNavBar({required this.child});

  int _locationToIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/goals')) return 1;
    if (location.startsWith('/shop')) return 2;
    if (location.startsWith('/stats')) return 3;
    if (location.startsWith('/profile')) return 4;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/goals');
        break;
      case 2:
        context.go('/shop');
        break;
      case 3:
        context.go('/stats');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Перехватываем системную кнопку "Назад"
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final location = GoRouterState.of(context).matchedLocation;
        // Если не на главной — идём на главную
        if (location != '/') {
          context.go('/');
        } else {
          // На главной — сворачиваем приложение вместо выхода
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _locationToIndex(context),
          onDestinationSelected: (index) =>
              _onDestinationSelected(context, index),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.today_outlined),
              selectedIcon: Icon(Icons.today),
              label: 'Сегодня',
            ),
            NavigationDestination(
              icon: Icon(Icons.flag_outlined),
              selectedIcon: Icon(Icons.flag),
              label: 'Цели',
            ),
            NavigationDestination(
              icon: Icon(Icons.storefront_outlined),
              selectedIcon: Icon(Icons.storefront),
              label: 'Магазин',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart),
              label: 'Статистика',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}