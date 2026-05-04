import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/isar_service.dart';
import 'shared/points_provider.dart';
import 'features/shop/data/reward_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Глобальный обработчик — не даём упасть из-за навигации
  FlutterError.onError = (FlutterErrorDetails details) {
    final error = details.exception.toString();
    // Игнорируем ошибку стека go_router
    if (error.contains('currentConfiguration.isNotEmpty') ||
        error.contains('pages left to show')) {
      return;
    }
    FlutterError.presentError(details);
  };

  await IsarService.init();
  await RewardRepository().seedDefaultRewards();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PointsProvider()..load(),
      child: const App(),
    ),
  );
}