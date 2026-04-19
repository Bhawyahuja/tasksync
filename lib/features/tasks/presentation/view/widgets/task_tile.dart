import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tasksync/app/app_colors.dart';
import 'package:tasksync/app/app_messages.dart';
import 'package:tasksync/app/widgets/app_confirmation_dialog.dart';
import 'package:tasksync/features/tasks/domain/entities/task.dart';
import 'package:tasksync/features/tasks/presentation/view_model/task_bloc.dart';
import 'package:tasksync/features/tasks/presentation/view_model/task_event.dart';

class TaskTile extends StatefulWidget {
  const TaskTile({required this.task, super.key});

  final Task task;

  @override
  State<TaskTile> createState() => TaskTileState();
}

class TaskTileState extends State<TaskTile> {
  static const Duration _deleteAnimationDuration = Duration(milliseconds: 260);

  bool _isDeleting = false;

  @override
  void didUpdateWidget(covariant TaskTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.task.id != widget.task.id && _isDeleting) {
      _isDeleting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final task = widget.task;
    final textTheme = Theme.of(context).textTheme;

    return AnimatedSize(
      duration: _deleteAnimationDuration,
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        opacity: _isDeleting ? 0 : 1,
        duration: _deleteAnimationDuration,
        child: AnimatedSlide(
          offset: _isDeleting ? const Offset(-0.05, 0) : Offset.zero,
          duration: _deleteAnimationDuration,
          curve: Curves.easeOut,
          child: Dismissible(
            key: ValueKey<int>(task.id),
            direction: DismissDirection.endToStart,
            background: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.primaryWithOpacity(0.28),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Icon(Icons.delete_outline, color: AppColors.plum),
                ),
              ),
            ),
            confirmDismiss: (_) => _confirmDelete(),
            onDismissed: (_) => context.read<TaskBloc>().add(TaskDeleted(task)),
            child: Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 10),
              color: AppColors.card.withValues(
                alpha: task.completed ? 0.78 : 0.94,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.62)),
              ),
              child: ListTile(
                tileColor: task.completed
                    ? AppColors.lavender.withValues(alpha: 0.08)
                    : AppColors.peach.withValues(alpha: 0.13),
                minVerticalPadding: 12,
                contentPadding: const EdgeInsets.fromLTRB(6, 4, 6, 4),
                horizontalTitleGap: 2,
                leading: Checkbox(
                  value: task.completed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: _isDeleting
                      ? null
                      : (value) {
                          context.read<TaskBloc>().add(
                            TaskCompletionToggled(
                              task: task,
                              completed: value ?? false,
                            ),
                          );
                        },
                ),
                title: Text(
                  task.title,
                  style: textTheme.bodyLarge?.copyWith(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                    color: task.completed
                        ? AppColors.plumWithOpacity(0.52)
                        : AppColors.plum,
                    fontWeight: task.completed
                        ? FontWeight.w500
                        : FontWeight.w600,
                  ),
                ),
                trailing: IconButton(
                  tooltip: 'Delete task',
                  onPressed: _isDeleting ? null : _deleteTask,
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTask() async {
    final confirmed = await _confirmDelete();
    if (!confirmed || !mounted) {
      return;
    }

    setState(() {
      _isDeleting = true;
    });
    await Future<void>.delayed(_deleteAnimationDuration);

    if (!mounted) {
      return;
    }

    context.read<TaskBloc>().add(TaskDeleted(widget.task));
  }

  Future<bool> _confirmDelete() {
    return AppConfirmationDialog.show(
      context,
      title: 'Delete task?',
      message: AppMessages.deleteTaskConfirmation,
      confirmLabel: 'Delete',
      isDestructive: true,
    );
  }
}
