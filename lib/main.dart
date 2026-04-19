import 'package:flutter/material.dart';

import 'app/app_bootstrap.dart';
import 'app/task_sync_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await bootstrapApp();

  runApp(
    TaskSyncApp(
      taskRepository: bootstrap.taskRepository,
      authLocalDataSource: bootstrap.authLocalDataSource,
    ),
  );
}
