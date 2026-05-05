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

  @override
  Widget build(BuildContext context) {
    final userPoints = context.watch<PointsProvider>().points;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0047AB),
        title: const Text('Магазин наград',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$userPoints \u{2B50}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
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
                  '${state.purchased.iconEmoji} ${state.purchased.title} куплено! -${state.pointsSpent} \u{2B50}',
                ),
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
                  const Text('Магазин пуст',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(
                    'Нажми + чтобы добавить награду',
                    style: TextStyle(color: Colors.white38, fontSize: 14),
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
              return _RewardCard(
                reward: reward,
                userPoints: userPoints,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0047AB),
        onPressed: () => _AddRewardSheet.show(context),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Карточка награды — отдельный StatefulWidget
// ─────────────────────────────────────────
class _RewardCard extends StatelessWidget {
  final Reward reward;
  final int userPoints;

  const _RewardCard({
    required this.reward,
    required this.userPoints,
  });

  Future<void> _onTap(BuildContext context) async {
    if (reward.isPurchased) return;

    final canAfford = userPoints >= reward.cost;

    // Сохраняем bloc ДО диалога
    final shopBloc = context.read<ShopBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Column(
          children: [
            Text(
              reward.iconEmoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              reward.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (reward.description != null)
              Text(
                reward.description!,
                style: const TextStyle(
                    color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: canAfford
                    ? const Color(0xFF0047AB).withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Стоимость: ${reward.cost} \u{2B50}',
                style: TextStyle(
                  color: canAfford
                      ? const Color(0xFF4DA6FF)
                      : Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (!canAfford) ...[
              const SizedBox(height: 8),
              Text(
                'Не хватает ${reward.cost - userPoints} \u{2B50}',
                style: const TextStyle(
                    color: Colors.red, fontSize: 13),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: canAfford
                ? () => Navigator.of(ctx).pop(true)
                : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
            ),
            child: const Text('Купить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Используем сохранённый bloc
    shopBloc.add(PurchaseRewardEvent(reward.id));
  }

  Future<void> _onDelete(BuildContext context) async {
    final shopBloc = context.read<ShopBloc>();

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Удалить награду?',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '${reward.iconEmoji} ${reward.title} будет удалена',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Отмена',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style:
                FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    shopBloc.add(DeleteRewardEvent(reward.id));
  }

  @override
  Widget build(BuildContext context) {
    final isPurchased = reward.isPurchased;
    final canAfford = userPoints >= reward.cost;

    return Card(
      color: const Color(0xFF1C1C1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: isPurchased ? null : () => _onTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Кнопка удаления
            Positioned(
              top: 6,
              right: 6,
              child: GestureDetector(
                onTap: () => _onDelete(context),
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close,
                      size: 14, color: Colors.red),
                ),
              ),
            ),

            // Контент
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    reward.iconEmoji,
                    style: const TextStyle(fontSize: 38),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
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
                      child: const Text(
                        '\u{2713} Куплено',
                        style: TextStyle(
                            color: Colors.green, fontSize: 12),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: canAfford
                            ? const Color(0xFF0047AB).withOpacity(0.2)
                            : Colors.red.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${reward.cost} \u{2B50}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: canAfford
                              ? const Color(0xFF4DA6FF)
                              : Colors.red,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────
// Добавление награды — отдельный StatefulWidget
// ─────────────────────────────────────────
class _AddRewardSheet extends StatefulWidget {
  const _AddRewardSheet();

  static void show(BuildContext context) {
    final shopBloc = context.read<ShopBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => BlocProvider.value(
        value: shopBloc,
        child: const _AddRewardSheet(),
      ),
    );
  }

  @override
  State<_AddRewardSheet> createState() => _AddRewardSheetState();
}

class _AddRewardSheetState extends State<_AddRewardSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _costController = TextEditingController(text: '50');
  String _selectedEmoji = '\u{1F381}';
  RewardType _selectedType = RewardType.virtual;

  final List<String> _emojis = [
    '\u{1F381}', '\u{1F3AC}', '\u{1F3AE}', '\u{1F370}',
    '\u{2615}',  '\u{1F4DA}', '\u{1F3D6}', '\u{1F3B5}',
    '\u{1F6CD}', '\u{1F355}', '\u{1F3AF}', '\u{1F486}',
    '\u{1F697}', '\u{2708}',  '\u{1F3B2}', '\u{1F3CB}',
    '\u{1F3A8}', '\u{1F366}',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final cost = int.tryParse(_costController.text) ?? 50;
    if (cost <= 0) return;

    final reward = Reward()
      ..title = _titleController.text.trim()
      ..description = _descController.text.trim().isEmpty
          ? null
          : _descController.text.trim()
      ..cost = cost
      ..iconEmoji = _selectedEmoji
      ..type = _selectedType;

    context.read<ShopBloc>().add(AddRewardEvent(reward));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Новая награда',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),

            // Выбор эмодзи
            const Text('Иконка',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: GridView.builder(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 6,
                  mainAxisSpacing: 6,
                ),
                itemCount: _emojis.length,
                itemBuilder: (_, i) {
                  final emoji = _emojis[i];
                  final selected = emoji == _selectedEmoji;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedEmoji = emoji),
                    child: Container(
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF0047AB).withOpacity(0.3)
                            : const Color(0xFF2C2C2E),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF0047AB)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Название
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('Название *'),
            ),
            const SizedBox(height: 10),

            // Описание
            TextField(
              controller: _descController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('Описание (необязательно)'),
            ),
            const SizedBox(height: 10),

            // Стоимость
            TextField(
              controller: _costController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecor('Стоимость в баллах \u{2B50}'),
            ),
            const SizedBox(height: 12),

            // Тип
            const Text('Тип награды',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _TypeButton(
                    emoji: '\u{1F3AE}',
                    label: 'Виртуальная',
                    selected: _selectedType == RewardType.virtual,
                    onTap: () => setState(
                        () => _selectedType = RewardType.virtual),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _TypeButton(
                    emoji: '\u{1F381}',
                    label: 'Реальная',
                    selected: _selectedType == RewardType.real,
                    onTap: () =>
                        setState(() => _selectedType = RewardType.real),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF0047AB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Добавить',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecor(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF0047AB), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFF2C2C2E),
      );
}

class _TypeButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TypeButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0047AB).withOpacity(0.2)
              : const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? const Color(0xFF0047AB)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                  color: selected ? Colors.white : Colors.white54,
                  fontSize: 12,
                )),
          ],
        ),
      ),
    );
  }
}