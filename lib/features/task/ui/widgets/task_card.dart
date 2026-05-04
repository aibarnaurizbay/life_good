import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/task_model.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onDelete;
  final Function(Task) onEdit;

  const TaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onDelete,
    required this.onEdit,
  });

  void _showEditDialog(BuildContext context) {
    final titleController = TextEditingController(text: task.title);
    int priority = task.priority;
    DateTime? deadline = task.deadline;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C1C1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Редактировать задачу',
            style: TextStyle(color: Colors.white, fontSize: 17),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Название',
                    labelStyle:
                        const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.white24),
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
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  value: priority,
                  dropdownColor: const Color(0xFF2C2C2E),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Приоритет',
                    labelStyle:
                        const TextStyle(color: Colors.white54),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          const BorderSide(color: Colors.white24),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2C2C2E),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 1, child: Text('\u{1F7E2} Низкий')),
                    DropdownMenuItem(
                        value: 2, child: Text('\u{1F7E1} Средний')),
                    DropdownMenuItem(
                        value: 3, child: Text('\u{1F534} Высокий')),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => priority = v!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(color: Colors.white54)),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;
                final updated = task
                  ..title = titleController.text.trim()
                  ..priority = priority;
                onEdit(updated);
                Navigator.pop(ctx);
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

  Color _priorityColor() {
    switch (task.priority) {
      case 3:
        return Colors.red;
      case 2:
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: GestureDetector(
          onTap: onComplete,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.grey.shade300,
                width: 1.5,
              ),
            ),
          ),
        ),
        title: Text(
          task.title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Color(0xFF1C1C1E),
          ),
        ),
        subtitle: task.deadline != null
            ? Text(
                DateFormat('d MMM').format(task.deadline!),
                style: TextStyle(
                  fontSize: 12,
                  color: task.isOverdue ? Colors.red : Colors.grey,
                ),
              )
            : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_horiz,
              color: Colors.grey, size: 20),
          onSelected: (v) {
            if (v == 'edit') _showEditDialog(context);
            if (v == 'delete') onDelete();
            if (v == 'complete') onComplete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'complete',
              child: Row(
                children: [
                  Icon(Icons.check_circle_outline,
                      color: Colors.green, size: 18),
                  SizedBox(width: 8),
                  Text('Выполнить'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit_outlined,
                      color: Colors.blue, size: 18),
                  SizedBox(width: 8),
                  Text('Редактировать'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline,
                      color: Colors.red, size: 18),
                  SizedBox(width: 8),
                  Text('Удалить'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}