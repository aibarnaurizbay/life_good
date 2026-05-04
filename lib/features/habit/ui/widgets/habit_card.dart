import 'package:flutter/material.dart';
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
  // Локально отмеченные дни (помимо сегодняшнего из БД)
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

  void _onDayTap(BuildContext context, DateTime date) {
    // Прошлые дни — показываем диалог
    if (!_isToday(date)) {
      _showConfirmDialog(context, date);
      return;
    }
    // Сегодня — стандартное выполнение
    if (!widget.habit.isCompletedToday) {
      widget.onComplete();
    }
  }

  void _showConfirmDialog(BuildContext context, DateTime date) {
    final alreadyMarked = _markedDays.contains(date.day);
    if (alreadyMarked) return; // уже отмечен — не показываем

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Text('\u{1F4C5}', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              '${date.day} ${_monthName(date.month)}',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
        content: Text(
          'Привычка "${widget.habit.title}" выполнена?',
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey,
              side: const BorderSide(color: Colors.grey),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Нет'),
          ),
          FilledButton(
            onPressed: () {
              setState(() => _markedDays.add(date.day));
              Navigator.pop(context);
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
      'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек',
    ];
    return names[month - 1];
  }

  int _overallPercent() {
    if (widget.habit.longestStreak == 0) return 0;
    final ratio =
        widget.habit.currentStreak / widget.habit.longestStreak;
    return (ratio * 100).round().clamp(0, 100);
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
                      fontFamily: 'SF Pro Display',
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert,
                      color: Colors.white54, size: 20),
                  color: const Color(0xFF2C2C2E),
                  onSelected: (v) {
                    if (v == 'delete') widget.onDelete();
                    if (v == 'complete' && !isDone) widget.onComplete();
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
                    fontFamily: 'SF Pro Text',
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
                    fontFamily: 'SF Pro Text',
                    fontSize: 13,
                    color: Colors.white54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '+${widget.habit.pointsReward}\u{2B50}',
                  style: const TextStyle(
                    fontFamily: 'SF Pro Text',
                    fontSize: 13,
                    color: Color(0xFF4DA6FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Разделитель
          Divider(
            height: 1,
            color: Colors.white.withOpacity(0.08),
          ),

          // Дни недели — кликабельные
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: days.map((day) {
                final isToday = _isToday(day);
                final completed = _isDayCompleted(day);

                return GestureDetector(
                  onTap: () => _onDayTap(context, day),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: completed
                              ? const Color(0xFF0047AB) // кобальт
                              : isToday
                                  ? const Color(0xFF0047AB).withOpacity(0.25)
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
                                    fontFamily: 'SF Pro Text',
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
                              fontFamily: 'SF Pro Text',
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