import 'package:flutter/material.dart';

import '../../../../../app/app_colors.dart';
import '../../../../../app/widgets/app_text_field.dart';
import '../../view_model/task_state.dart';

class TaskHeader extends StatelessWidget {
  const TaskHeader({
    required this.state,
    required this.searchController,
    required this.onSearchChanged,
    required this.onClearSearch,
    required this.onFilterChanged,
    super.key,
  });

  final TaskState state;
  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onClearSearch;
  final ValueChanged<TaskFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final totalCount = state.tasks.length;
    final completedCount = state.completedCount;
    final progress = totalCount == 0 ? 0.0 : completedCount / totalCount;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.plumWithOpacity(0.14),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'My Tasks',
                      style: textTheme.headlineSmall?.copyWith(
                        color: AppColors.plum,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Text(
                    totalCount == 0
                        ? 'No todos'
                        : '$completedCount/$totalCount done',
                    style: textTheme.labelLarge?.copyWith(
                      color: AppColors.plumWithOpacity(0.62),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: totalCount == 0 ? null : progress,
                  color: AppColors.primary,
                  backgroundColor: AppColors.primaryWithOpacity(0.12),
                ),
              ),
              const SizedBox(height: 16),
              _TaskFilterTabs(
                selectedFilter: state.filter,
                onChanged: onFilterChanged,
              ),
              const SizedBox(height: 14),
              AppTextField(
                controller: searchController,
                onChanged: onSearchChanged,
                fillColor: AppColors.primaryWithOpacity(0.1),
                hintText: 'Search todos',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.searchQuery.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Clear search',
                        onPressed: onClearSearch,
                        icon: const Icon(Icons.close),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskFilterTabs extends StatelessWidget {
  const _TaskFilterTabs({
    required this.selectedFilter,
    required this.onChanged,
  });

  final TaskFilter selectedFilter;
  final ValueChanged<TaskFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<TaskFilter>(
      showSelectedIcon: false,
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white.withValues(alpha: 0.72);
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return AppColors.plum;
        }),
        side: WidgetStatePropertyAll(
          BorderSide(color: AppColors.primaryWithOpacity(0.12)),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      segments: TaskFilter.values
          .map((filter) {
            return ButtonSegment<TaskFilter>(
              value: filter,
              label: Text(filter.label),
            );
          })
          .toList(growable: false),
      selected: <TaskFilter>{selectedFilter},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
