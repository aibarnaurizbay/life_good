import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/habit_bloc.dart';
import '../../bloc/habit_event.dart';
import '../../data/habit_model.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  final Set<int> _markedDays = {};

  List<DateTime> _lastSevenDays() {
    final today = DateTime.now();
    return List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));
  }

  String _dayLabel(DateTime date) {
    const labels = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return labels[date.weekday - 1];
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isDayCompleted(DateTime date) {
    if (_isToday(date)) return widget.habit.isCompletedToday;
    return _markedDays.contains(date.day);
  }

  void _onDayTap(DateTime date) {
    if (_isToday(date)) {
      if (!widget.habit.isCompletedToday) {
        _showConfirmDialog(date, isToday: true);
      }
      return;
    }
    if (!_markedDays.contains(date.day)) {
      _showConfirmDialog(date, isToday: false);
    }
  }

  void _showConfirmDialog(DateTime date, {required bool isToday}) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Text('\u{1F4C5}', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              isToday ? 'Сегодня' : '${date.day} ${_monthName(date.month)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Привычка "${widget.habit.title}" выполнена?',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (isToday) {
                widget.onComplete();
              } else {
                setState(() => _markedDays.add(date.day));
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog() {
    // Сохраняем bloc ДО открытия диалога
    final habitBloc = context.read<HabitBloc>();
    final titleController =
        TextEditingController(text: widget.habit.title);
    int points = widget.habit.pointsReward;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Редактировать привычку',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Название',
                  labelStyle: const TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF0047AB), width: 2),
                  ),
                  filled: true,
                  fillColor: const Color(0xFF2C2C2E),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Баллов: ',
                    style: TextStyle(color: Colors.white70),
                  ),
                  Expanded(
                    child: Slider(
                      value: points.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: const Color(0xFF0047AB),
                      label: '$points',
                      onChanged: (v) =>
                          setDialogState(() => points = v.round()),
                    ),
                  ),
                  Text(
                    '$points \u{2B50}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text(
                'Отмена',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                // Используем сохранённый bloc, не context диалога
                final updated = widget.habit
                  ..title = titleController.text.trim()
                  ..pointsReward = points;
                habitBloc.add(UpdateHabitEvent(updated));
                Navigator.of(dialogContext).pop();
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0047AB),
              ),
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }

  void _openFullCalendar() {
    final habitBloc = context.read<HabitBloc>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => _FullCalendarSheet(
        habit: widget.habit,
        markedDays: _markedDays,
        onDayMarked: (day) => setState(() => _markedDays.add(day)),
        onComplete: widget.onComplete,
        habitBloc: habitBloc,
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return names[month - 1];
  }

  int _overallPercent() {
    if (widget.habit.longestStreak == 0) return 0;
    return ((widget.habit.currentStreak / widget.habit.longestStreak) * 100)
        .round()
        .clamp(0, 100);
  }

  @override
  Widget build(BuildContext context) {
    final isDone = widget.habit.isCompletedToday;
    final days = _lastSevenDays();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.habit.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month_outlined,
                      color: Color(0xFF4DA6FF), size: 20),
                  onPressed: _openFullCalendar,
                  tooltip: 'Календарь',
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white54, size: 20),
                  color: const Color(0xFF2C2C2E),
                  onSelected: (v) {
                    if (v == 'edit') _showEditDialog();
                    if (v == 'delete') widget.onDelete();
                    if (v == 'complete' && !isDone) {
                      _showConfirmDialog(DateTime.now(), isToday: true);
                    }
                  },
                  itemBuilder: (_) => [
                    if (!isDone)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_outline,
                                color: Colors.green),
                            SizedBox(width: 8),
                            Text('Выполнено',
                                style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('Редактировать',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Streak / Overall / баллы
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 12),
            child: Row(
              children: [
                Text(
                  'Streak: +${widget.habit.currentStreak}',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.habit.currentStreak > 0
                        ? Colors.orange
                        : Colors.white38,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Overall: ${_overallPercent()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '+${widget.habit.pointsReward}\u{2B50}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF4DA6FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white.withOpacity(0.08)),

          // 7 дней
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isToday = _isToday(day);
                final completed = _isDayCompleted(day);

                return GestureDetector(
                  onTap: () => _onDayTap(day),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed
                              ? const Color(0xFF0047AB)
                              : isToday
                                  ? const Color(0xFF0047AB).withOpacity(0.2)
                                  : const Color(0xFF2C2C2E),
                          border: isToday && !completed
                              ? Border.all(
                                  color: const Color(0xFF0047AB),
                                  width: 1.5,
                                )
                              : null,
                        ),
                        child: Center(
                          child: completed
                              ? const Icon(Icons.check,
                                  color: Colors.white, size: 18)
                              : Text(
                                  _dayLabel(day),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isToday
                                        ? const Color(0xFF4DA6FF)
                                        : Colors.white38,
                                  ),
                                ),
                        ),
                      ),
                      if (isToday)
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            'TODAY',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0047AB),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────
// Полный календарь
// ─────────────────────────────────────────
class _FullCalendarSheet extends StatefulWidget {
  final Habit habit;
  final Set<int> markedDays;
  final Function(int) onDayMarked;
  final VoidCallback onComplete;
  final HabitBloc habitBloc;

  const _FullCalendarSheet({
    required this.habit,
    required this.markedDays,
    required this.onDayMarked,
    required this.onComplete,
    required this.habitBloc,
  });

  @override
  State<_FullCalendarSheet> createState() => _FullCalendarSheetState();
}

class _FullCalendarSheetState extends State<_FullCalendarSheet> {
  late DateTime _currentMonth;
  late Set<int> _localMarked;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _localMarked = Set.from(widget.markedDays);
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDay.weekday;

    final days = <DateTime?>[];
    for (int i = 1; i < startWeekday; i++) {
      days.add(null);
    }
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    return days;
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool _isFuture(DateTime date) {
    final now = DateTime.now();
    return date.isAfter(DateTime(now.year, now.month, now.day));
  }

  bool _isCompleted(DateTime date) {
    if (_isToday(date)) return widget.habit.isCompletedToday;
    if (date.month == DateTime.now().month) {
      return _localMarked.contains(date.day);
    }
    return false;
  }

  void _onDayTap(DateTime date) {
    if (_isFuture(date) || _isCompleted(date)) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          _isToday(date) ? 'Сегодня' : '${date.day} ${_monthName(date.month)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Привычка "${widget.habit.title}" выполнена?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white54,
              side: const BorderSide(color: Colors.white24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              if (_isToday(date)) {
                widget.onComplete();
              } else {
                setState(() => _localMarked.add(date.day));
                widget.onDayMarked(date.day);
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const names = [
      'Январь', 'Февраль', 'Март', 'Апрель',
      'Май', 'Июнь', 'Июль', 'Август',
      'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь',
    ];
    return names[month - 1];
  }

  @override
  Widget build(BuildContext context) {
    final calDays = _buildCalendarDays();
    final now = DateTime.now();

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Color(0xFF4DA6FF), size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.habit.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                _StatBadge(
                  label: 'Серия',
                  value: '${widget.habit.currentStreak} дней',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'Рекорд',
                  value: '${widget.habit.longestStreak} дней',
                  color: const Color(0xFF4DA6FF),
                ),
                const SizedBox(width: 8),
                _StatBadge(
                  label: 'Баллов',
                  value: '+${widget.habit.pointsReward}',
                  color: Colors.amber,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Навигация месяц
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left,
                      color: Colors.white70),
                  onPressed: () => setState(() {
                    _currentMonth = DateTime(
                        _currentMonth.year, _currentMonth.month - 1);
                  }),
                ),
                Text(
                  '${_monthName(_currentMonth.month)} ${_currentMonth.year}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right,
                      color: Colors.white70),
                  onPressed: _currentMonth.year == now.year &&
                          _currentMonth.month == now.month
                      ? null
                      : () => setState(() {
                            _currentMonth = DateTime(
                                _currentMonth.year,
                                _currentMonth.month + 1);
                          }),
                ),
              ],
            ),
          ),

          // Заголовки дней
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Сетка
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: calDays.length,
                itemBuilder: (_, i) {
                  final date = calDays[i];
                  if (date == null) return const SizedBox();

                  final isToday = _isToday(date);
                  final isFuture = _isFuture(date);
                  final completed = _isCompleted(date);

                  return GestureDetector(
                    onTap: isFuture ? null : () => _onDayTap(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? const Color(0xFF0047AB)
                            : isToday
                                ? const Color(0xFF0047AB).withOpacity(0.2)
                                : Colors.transparent,
                        border: isToday && !completed
                            ? Border.all(
                                color: const Color(0xFF0047AB),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 16)
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isToday
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isFuture
                                      ? Colors.white12
                                      : isToday
                                          ? const Color(0xFF4DA6FF)
                                          : Colors.white70,
                                ),
                              ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Легенда
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendItem(
                  color: const Color(0xFF0047AB),
                  label: 'Выполнено',
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: const Color(0xFF0047AB).withOpacity(0.2),
                  label: 'Сегодня',
                  isBorder: true,
                ),
                const SizedBox(width: 16),
                _LegendItem(
                  color: Colors.white12,
                  label: 'Будущее',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatBadge({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white38,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isBorder;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: isBorder
                ? Border.all(
                    color: const Color(0xFF0047AB), width: 1.5)
                : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 11),
        ),
      ],
    );
  }
}