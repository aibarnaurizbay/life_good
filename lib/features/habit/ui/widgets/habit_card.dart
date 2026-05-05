import 'package:flutter/material.dart';
import '../../data/habit_model.dart';

class HabitCard extends StatefulWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final Function(String title, int points) onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
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

  String _monthName(int month) {
    const names = [
      'янв','фев','мар','апр','май','июн',
      'июл','авг','сен','окт','ноя','дек',
    ];
    return names[month - 1];
  }

  int _overallPercent() {
    if (widget.habit.longestStreak == 0) return 0;
    return ((widget.habit.currentStreak / widget.habit.longestStreak) * 100)
        .round()
        .clamp(0, 100);
  }

  // Диалог подтверждения — без BLoC внутри
  Future<bool> _askConfirm(String title) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Привычка "${widget.habit.title}" выполнена?',
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Нет',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF0047AB),
            ),
            child: const Text('Да'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _onDayTap(DateTime date) async {
    final isToday = _isToday(date);

    if (isToday && widget.habit.isCompletedToday) return;
    if (!isToday && _markedDays.contains(date.day)) return;

    final label = isToday ? 'Сегодня' : '${date.day} ${_monthName(date.month)}';
    final confirmed = await _askConfirm(label);

    if (!confirmed) return;
    if (!mounted) return;

    if (isToday) {
      widget.onComplete();
    } else {
      setState(() => _markedDays.add(date.day));
    }
  }

  void _onEditTap() async {
    final titleController =
        TextEditingController(text: widget.habit.title);
    int points = widget.habit.pointsReward;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
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
                  const Text('Баллов: ',
                      style: TextStyle(color: Colors.white70)),
                  Expanded(
                    child: Slider(
                      value: points.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: const Color(0xFF0047AB),
                      label: '$points',
                      onChanged: (v) => setS(() => points = v.round()),
                    ),
                  ),
                  Text('$points \u{2B50}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(null),
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                Navigator.of(ctx).pop({
                  'title': titleController.text.trim(),
                  'points': points,
                });
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

    if (!mounted) return;
    if (result == null) return;

    widget.onEdit(result['title'] as String, result['points'] as int);
  }

  void _onCalendarTap() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _FullCalendarSheet(
        habit: widget.habit,
        markedDays: Set.from(_markedDays),
        onDayMarked: (day) {
          if (mounted) setState(() => _markedDays.add(day));
        },
        onTodayComplete: widget.onComplete,
      ),
    );
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
          // Заголовок + кнопки
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 4, 0),
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
                  onPressed: _onCalendarTap,
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white54, size: 20),
                  color: const Color(0xFF2C2C2E),
                  onSelected: (v) {
                    switch (v) {
                      case 'complete':
                        if (!isDone) _onDayTap(DateTime.now());
                        break;
                      case 'edit':
                        _onEditTap();
                        break;
                      case 'delete':
                        widget.onDelete();
                        break;
                    }
                  },
                  itemBuilder: (_) => [
                    if (!isDone)
                      const PopupMenuItem(
                        value: 'complete',
                        child: Row(children: [
                          Icon(Icons.check_circle_outline,
                              color: Colors.green, size: 18),
                          SizedBox(width: 8),
                          Text('Выполнено',
                              style: TextStyle(color: Colors.white)),
                        ]),
                      ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_outlined,
                            color: Colors.blue, size: 18),
                        SizedBox(width: 8),
                        Text('Редактировать',
                            style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(children: [
                        Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Удалить',
                            style: TextStyle(color: Colors.white)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Streak info
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
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(width: 12),
                Text(
                  '+${widget.habit.pointsReward}\u{2B50}',
                  style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4DA6FF),
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.white.withOpacity(0.08)),

          // 7 дней
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
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
                                  ? const Color(0xFF0047AB)
                                      .withOpacity(0.2)
                                  : const Color(0xFF2C2C2E),
                          border: isToday && !completed
                              ? Border.all(
                                  color: const Color(0xFF0047AB),
                                  width: 1.5)
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
                          child: Text('TODAY',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0047AB),
                              )),
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
  final VoidCallback onTodayComplete;

  const _FullCalendarSheet({
    required this.habit,
    required this.markedDays,
    required this.onDayMarked,
    required this.onTodayComplete,
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
    _currentMonth =
        DateTime(DateTime.now().year, DateTime.now().month);
    _localMarked = Set.from(widget.markedDays);
  }

  List<DateTime?> _buildCalendarDays() {
    final firstDay =
        DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay =
        DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final days = <DateTime?>[];
    for (int i = 1; i < firstDay.weekday; i++) days.add(null);
    for (int i = 1; i <= lastDay.day; i++) {
      days.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }
    return days;
  }

  bool _isToday(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _isFuture(DateTime d) {
    final n = DateTime.now();
    return d.isAfter(DateTime(n.year, n.month, n.day));
  }

  bool _isCompleted(DateTime d) {
    if (_isToday(d)) return widget.habit.isCompletedToday;
    if (d.month == DateTime.now().month) {
      return _localMarked.contains(d.day);
    }
    return false;
  }

  Future<void> _onDayTap(DateTime date) async {
    if (_isFuture(date) || _isCompleted(date)) return;

    final label = _isToday(date)
        ? 'Сегодня'
        : '${date.day} ${_monthShort(date.month)}';

    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(label,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
        content: Text(
          'Привычка "${widget.habit.title}" выполнена?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Нет',
                style: TextStyle(color: Colors.white54)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0047AB)),
            child: const Text('Да'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!mounted) return;

    if (_isToday(date)) {
      widget.onTodayComplete();
      Navigator.of(context).pop();
    } else {
      setState(() => _localMarked.add(date.day));
      widget.onDayMarked(date.day);
    }
  }

  String _monthName(int m) {
    const n = [
      'Январь','Февраль','Март','Апрель',
      'Май','Июнь','Июль','Август',
      'Сентябрь','Октябрь','Ноябрь','Декабрь'
    ];
    return n[m - 1];
  }

  String _monthShort(int m) {
    const n = [
      'янв','фев','мар','апр','май','июн',
      'июл','авг','сен','окт','ноя','дек'
    ];
    return n[m - 1];
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
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              const Icon(Icons.calendar_month,
                  color: Color(0xFF4DA6FF), size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(widget.habit.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
            ]),
          ),
          const SizedBox(height: 12),

          // Статистика
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              _Badge('${widget.habit.currentStreak} дн.', 'Серия',
                  Colors.orange),
              const SizedBox(width: 8),
              _Badge('${widget.habit.longestStreak} дн.', 'Рекорд',
                  const Color(0xFF4DA6FF)),
              const SizedBox(width: 8),
              _Badge('+${widget.habit.pointsReward}', 'Баллов',
                  Colors.amber),
            ]),
          ),
          const SizedBox(height: 16),

          // Навигация
          Row(
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
                    fontWeight: FontWeight.w600),
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

          // Заголовки дней
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['Пн','Вт','Ср','Чт','Пт','Сб','Вс']
                  .map((d) => SizedBox(
                        width: 36,
                        child: Center(
                          child: Text(d,
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 4),

          // Сетка
          Expanded(
            child: SingleChildScrollView(
              controller: controller,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
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
                    onTap: isFuture
                        ? null
                        : () => _onDayTap(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: completed
                            ? const Color(0xFF0047AB)
                            : isToday
                                ? const Color(0xFF0047AB)
                                    .withOpacity(0.2)
                                : Colors.transparent,
                        border: isToday && !completed
                            ? Border.all(
                                color: const Color(0xFF0047AB),
                                width: 1.5)
                            : null,
                      ),
                      child: Center(
                        child: completed
                            ? const Icon(Icons.check,
                                color: Colors.white, size: 14)
                            : Text(
                                '${date.day}',
                                style: TextStyle(
                                  fontSize: 12,
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _Badge(this.value, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.bold)),
        Text(label,
            style: const TextStyle(
                color: Colors.white38, fontSize: 10)),
      ]),
    );
  }
}