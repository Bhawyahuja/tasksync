import 'package:flutter/material.dart';

import '../../../../../app/app_colors.dart';
import '../../../../../app/widgets/app_text_field.dart';

class AddTaskSheet extends StatefulWidget {
  const AddTaskSheet({super.key});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  late final TextEditingController _titleController;
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _titleController.addListener(_updateSubmitState);
  }

  @override
  void dispose() {
    _titleController.removeListener(_updateSubmitState);
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            "What's on your mind?",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.plum,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          AppTextField(
            controller: _titleController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _submit(context),
            fillColor: AppColors.primaryWithOpacity(0.08),
            hintText: 'Add new task',
            prefixIcon: const Icon(Icons.edit_outlined),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _canSubmit ? () => _submit(context) : null,
            label: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _submit(BuildContext context) {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      return;
    }

    Navigator.of(context).pop(title);
  }

  void _updateSubmitState() {
    final canSubmit = _titleController.text.trim().isNotEmpty;
    if (canSubmit == _canSubmit) {
      return;
    }
    setState(() {
      _canSubmit = canSubmit;
    });
  }
}
