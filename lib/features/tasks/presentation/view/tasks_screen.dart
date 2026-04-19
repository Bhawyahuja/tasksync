import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_messages.dart';
import '../../../../app/widgets/app_confirmation_dialog.dart';
import '../../../auth/presentation/view_model/auth_cubit.dart';
import '../view_model/task_bloc.dart';
import '../view_model/task_event.dart';
import '../view_model/task_state.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/task_header.dart';
import 'widgets/task_list.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskBloc, TaskState>(
      listenWhen: (previous, current) =>
          previous.message != current.message && current.message != null,
      listener: (context, state) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(state.message!)));
      },
      builder: (context, state) {
        _syncSearchController(state.searchQuery);

        return Scaffold(
          extendBodyBehindAppBar: true,
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.cream,
          appBar: _TasksAppBar(
            state: state,
            onLogoutPressed: () => _confirmLogout(context),
          ),
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  AppColors.peach,
                  AppColors.coral,
                  AppColors.primary,
                  AppColors.lavender,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  TaskHeader(
                    state: state,
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onClearSearch: _clearSearch,
                    onFilterChanged: _onFilterChanged,
                  ),
                  Expanded(child: TaskList(state: state)),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton(
            tooltip: 'Add task',
            onPressed: () => _showAddTaskSheet(context),
            backgroundColor: AppColors.primary,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }

  void _syncSearchController(String query) {
    if (_searchController.text == query) {
      return;
    }

    _searchController.value = TextEditingValue(
      text: query,
      selection: TextSelection.collapsed(offset: query.length),
    );
  }

  void _onSearchChanged(String query) {
    context.read<TaskBloc>().add(TaskSearchChanged(query));
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<TaskBloc>().add(const TaskSearchChanged(''));
  }

  void _onFilterChanged(TaskFilter filter) {
    context.read<TaskBloc>().add(TaskFilterChanged(filter));
  }

  Future<void> _showAddTaskSheet(BuildContext context) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final title = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return const AddTaskSheet();
      },
    );
    if (!context.mounted || title == null) {
      return;
    }
    context.read<TaskBloc>().add(TaskAdded(title));
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await AppConfirmationDialog.show(
      context,
      title: 'Log out?',
      message: AppMessages.logOutConfirmation,
      confirmLabel: 'Log out',
      isDestructive: true,
    );
    if (!context.mounted || !confirmed) {
      return;
    }
    context.read<AuthCubit>().logout();
  }
}

class _TasksAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _TasksAppBar({required this.state, required this.onLogoutPressed});

  final TaskState state;
  final VoidCallback onLogoutPressed;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      title: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('TaskSync', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      actions: [
        IconButton(
          tooltip: state.isSyncing ? 'Syncing' : 'Sync saved changes',
          onPressed: state.isSyncing
              ? null
              : () => context.read<TaskBloc>().add(const TaskSyncRequested()),
          icon: state.isSyncing
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.cloud_upload_outlined),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: onLogoutPressed,
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }
}
