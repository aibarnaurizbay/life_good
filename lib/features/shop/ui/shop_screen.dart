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

  void _showAddRewardDialog(BuildContext context) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final costController = TextEditingController(text: '50');
    String selectedEmoji = '\u{1F381}';
    RewardType selectedType = RewardType.virtual;

    final emojis = [
      '\u{1F381}', '\u{1F3AC}', '\u{1F3AE}', '\u{1F370}',
      '\u{2615}',  '\u{1F4DA}', '\u{1F3D6}', '\u{1F3B5}',
      '\u{1F6CD}', '\u{1F355}', '\u{1F3AF}', '\u{1F486}',
      '\u{1F697}', '\u{2708}',  '\u{1F3B2}', '\u{1F3CB}',
      '\u{1F3A8}', '\u{1F366}',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Новая награда'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Иконка',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: emojis.length,
                    itemBuilder: (_, i) {
                      final emoji = emojis[i];
                      final isSelected = emoji == selectedEmoji;
                      return GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedEmoji = emoji),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Colors.transparent,
                            ),
                          ),
                          child: Center(
                            child: Text(emoji,
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Название *',
                    hintText: 'Например: Кино вечером',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Описание (необязательно)',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Стоимость в баллах',
                  ),
                ),
                const SizedBox(height: 12),
                Text('Тип награды',
                    style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(
                            () => selectedType = RewardType.virtual),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedType == RewardType.virtual
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedType == RewardType.virtual
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text('\u{1F3AE}',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 4),
                              Text('Виртуальная',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setDialogState(
                            () => selectedType = RewardType.real),
                        child: Container(
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selectedType == RewardType.real
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: selectedType == RewardType.real
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          child: const Column(
                            children: [
                              Text('\u{1F381}',
                                  style: TextStyle(fontSize: 20)),
                              SizedBox(height: 4),
                              Text('Реальная',
                                  style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final cost = int.tryParse(costController.text) ?? 50;
                if (cost <= 0) return;
                final reward = Reward()
                  ..title = titleController.text.trim()
                  ..description = descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim()
                  ..cost = cost
                  ..iconEmoji = selectedEmoji
                  ..type = selectedType;
                context.read<ShopBloc>().add(AddRewardEvent(reward));
                Navigator.pop(ctx);
              },
              child: const Text('Добавить'),
            ),
          ],
        ),
      ),
    );
  }

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
                const Text('\u{2B50}', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 4),
                Text('Стоимость: ${reward.cost} баллов',
                    style: Theme.of(context).textTheme.titleMedium),
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
              avatar: const Text('\u{2B50}',
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
                    '${state.purchased.iconEmoji} ${state.purchased.title} куплено! -${state.pointsSpent} \u{2B50}'),
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('\u{1F6CD}',
                      style: TextStyle(fontSize: 56)),
                  const SizedBox(height: 16),
                  Text('Магазин пуст',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Нажми + чтобы добавить первую награду',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(
                            color:
                                Theme.of(context).colorScheme.outline),
                  ),
                ],
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
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
                    : () =>
                        _confirmPurchase(context, reward, userPoints),
                onDelete: () => context
                    .read<ShopBloc>()
                    .add(DeleteRewardEvent(reward.id)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddRewardDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RewardCard extends StatelessWidget {
  final Reward reward;
  final bool canAfford;
  final VoidCallback? onTap;
  final VoidCallback onDelete;

  const _RewardCard({
    required this.reward,
    required this.canAfford,
    this.onTap,
    required this.onDelete,
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
          child: Stack(
            children: [
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Удалить награду?'),
                        content: Text(
                            '${reward.iconEmoji} ${reward.title} будет удалена'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Отмена'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                                backgroundColor: Colors.red),
                            onPressed: () {
                              Navigator.pop(context);
                              onDelete();
                            },
                            child: const Text('Удалить'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close,
                        size: 14, color: Colors.red),
                  ),
                ),
              ),
              Padding(
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
                        child: const Text('\u{2713} Куплено',
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
                          '${reward.cost} \u{2B50}',
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
            ],
          ),
        ),
      ),
    );
  }
}