import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../app/app_colors.dart';
import '../../../../../app/app_messages.dart';
import '../../view_model/task_bloc.dart';
import '../../view_model/task_event.dart';
import '../../view_model/task_state.dart';
import 'task_skeleton_list.dart';
import 'task_tile.dart';

class TaskList extends StatelessWidget {
  const TaskList({required this.state, super.key});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        final completer = Completer<void>();
        context.read<TaskBloc>().add(
          TaskLoadRequested(forceRefresh: true, completer: completer),
        );
        await completer.future;
      },
      child: _buildScrollableContent(context),
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    final filteredTasks = state.filteredTasks;

    if (state.tasks.isEmpty &&
        (state.status == TaskStatus.initial ||
            state.status == TaskStatus.loading)) {
      return const TaskSkeletonList();
    }

    if (state.status == TaskStatus.error && state.tasks.isEmpty) {
      return _TaskLoadError(onRetry: () => _retry(context));
    }

    if (filteredTasks.isEmpty) {
      return _EmptyTasksMessage(state: state);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return TaskTile(task: task);
      },
    );
  }

  void _retry(BuildContext context) {
    context.read<TaskBloc>().add(const TaskLoadRequested());
  }
}

class _TaskLoadError extends StatelessWidget {
  const _TaskLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 96),
        Icon(Icons.wifi_off_outlined, size: 48, color: AppColors.plum),
        const SizedBox(height: 16),
        Text(
          'Unable to load todos',
          textAlign: TextAlign.center,
          style: textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          AppMessages.loadErrorDetail,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ),
      ],
    );
  }
}

class _EmptyTasksMessage extends StatelessWidget {
  const _EmptyTasksMessage({required this.state});

  final TaskState state;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isSearching = state.searchQuery.isNotEmpty;
    final title = switch (state.filter) {
      TaskFilter.all => isSearching ? 'No matching todos' : 'No todos yet',
      TaskFilter.pending =>
        isSearching ? 'No pending match' : 'Nothing pending',
      TaskFilter.completed =>
        isSearching ? 'No completed match' : 'No completed todos',
    };
    final message = switch (state.filter) {
      TaskFilter.all =>
        isSearching
            ? 'Try a different keyword or clear search.'
            : 'Tap the add button to create your first task.',
      TaskFilter.pending =>
        isSearching
            ? 'Try another search while viewing pending tasks.'
            : 'You are all caught up.',
      TaskFilter.completed =>
        isSearching
            ? 'Try another search while viewing completed tasks.'
            : 'Completed tasks will appear here.',
    };

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 96),
        Icon(
          isSearching ? Icons.search_off : Icons.check_circle_outline,
          size: 48,
          color: AppColors.card,
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: textTheme.titleMedium?.copyWith(color: AppColors.card),
        ),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(color: AppColors.cream),
        ),
      ],
    );
  }
}
