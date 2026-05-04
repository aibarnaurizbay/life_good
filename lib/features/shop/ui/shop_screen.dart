import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../../shared/points_provider.dart';
import '../bloc/shop_bloc.dart';
import '../bloc/shop_event.dart';
import '../bloc/shop_state.dart';
import '../data/reward_model.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  void _confirmPurchase(
      BuildContext context, Reward reward, int userPoints) {
    final canAfford = userPoints >= reward.cost;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(reward.iconEmoji,
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(reward.title,
                style: Theme.of(context).textTheme.titleLarge),
            if (reward.description != null) ...[
              const SizedBox(height: 8),
              Text(
                reward.description!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('⭐',
                    style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text(
                  'Стоимость: ${reward.cost} баллов',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            if (!canAfford) ...[
              const SizedBox(height: 8),
              Text(
                'Не хватает ${reward.cost - userPoints} баллов',
                style: const TextStyle(color: Colors.red),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: canAfford
                        ? () {
                            Navigator.pop(context);
                            context
                                .read<ShopBloc>()
                                .add(PurchaseRewardEvent(reward.id));
                          }
                        : null,
                    child: const Text('Купить'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userPoints = context.watch<PointsProvider>().points;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Магазин наград'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              avatar: const Text('⭐',
                  style: TextStyle(fontSize: 14)),
              label: Text('$userPoints'),
            ),
          ),
        ],
      ),
      body: BlocConsumer<ShopBloc, ShopState>(
        listener: (context, state) {
          if (state is ShopPurchaseSuccess) {
            context.read<PointsProvider>().refresh();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${state.purchased.iconEmoji} ${state.purchased.title} куплено! -${state.pointsSpent} ⭐'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          } else if (state is ShopPurchaseFailed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.reason),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShopLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<Reward> rewards = [];
          if (state is ShopLoaded) rewards = state.rewards;
          if (state is ShopPurchaseSuccess) rewards = state.rewards;
          if (state is ShopPurchaseFailed) rewards = state.rewards;

          if (rewards.isEmpty) {
            return const Center(child: Text('Магазин пуст'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              final reward = rewards[index];
              final canAfford = userPoints >= reward.cost;
              return _RewardCard(
                reward: reward,
                canAfford: canAfford,
                onTap: reward.isPurchased
                    ? null
                    : () => _confirmPurchase(
                        context, reward, userPoints),
              );
            },
          );
        },
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool canAfford;
  final VoidCallback? onTap;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPurchased = reward.isPurchased;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Opacity(
          opacity: isPurchased ? 0.5 : 1.0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(reward.iconEmoji,
                    style: const TextStyle(fontSize: 40)),
                const SizedBox(height: 8),
                Text(
                  reward.title,
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                if (isPurchased)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('✓ Куплено',
                        style: TextStyle(
                            color: Colors.green, fontSize: 12)),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: canAfford
                          ? theme.colorScheme.primaryContainer
                          : theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${reward.cost} ⭐',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: canAfford
                            ? theme.colorScheme.onPrimaryContainer
                            : theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}