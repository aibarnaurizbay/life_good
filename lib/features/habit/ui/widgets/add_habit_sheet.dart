import 'package:flutter/material.dart';
import '../../data/habit_model.dart';

class AddHabitSheet extends StatefulWidget {
  final Function(Habit) onAdd;
  const AddHabitSheet({super.key, required this.onAdd});

  @override
  State<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends State<AddHabitSheet> {
  final _titleController = TextEditingController();
  String _frequency = 'daily';
  int _points = 10;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_titleController.text.trim().isEmpty) return;
    final habit = Habit()
      ..title = _titleController.text.trim()
      ..frequency = _frequency
      ..pointsReward = _points;
    widget.onAdd(habit);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text('Новая привычка', style: theme.textTheme.titleLarge),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Название',
              hintText: 'Например: Пить воду',
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _frequency,
            decoration: const InputDecoration(labelText: 'Частота'),
            items: const [
              DropdownMenuItem(value: 'daily', child: Text('Каждый день')),
              DropdownMenuItem(value: 'weekly', child: Text('По понедельникам')),
            ],
            onChanged: (v) => setState(() => _frequency = v!),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text('Баллов за выполнение: $_points ⭐',
                  style: theme.textTheme.bodyMedium),
              Expanded(
                child: Slider(
                  value: _points.toDouble(),
                  min: 5,
                  max: 50,
                  divisions: 9,
                  label: '$_points',
                  onChanged: (v) => setState(() => _points = v.round()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              child: const Text('Добавить привычку'),
            ),
          ),
        ],
      ),
    );
  }
}