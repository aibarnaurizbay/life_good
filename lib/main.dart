import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/isar_service.dart';
import 'shared/points_provider.dart';
import 'features/shop/data/reward_repository.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Инициализируем БД
  await IsarService.init();

  // 2. Сид стартовых наград (только при первом запуске)
  await RewardRepository().seedDefaultRewards();

  runApp(
    ChangeNotifierProvider(
      create: (_) => PointsProvider()..load(),
      child: const App(),
    ),
  );
}