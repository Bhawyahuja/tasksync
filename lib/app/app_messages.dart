abstract final class AppMessages {
  static const invalidCredentials = 'Invalid credentials.';

  static const cachedTodos = 'Showing cached todos. Pull to retry.';
  static const loadFailed =
      'Could not load todos. Check your connection and try again.';
  static const taskAdded = 'Task added successfully.';
  static const taskUpdated = 'Task updated.';
  static const taskDeleted = 'Task deleted.';
  static const savedOffline = 'Saved offline. Will sync automatically.';
  static const syncFailed = "Sync failed. We'll retry when online.";
  static const noPendingChanges = 'All changes are up to date.';
  static const syncStarted = 'Syncing saved changes...';
  static const syncCompleted = 'Sync completed.';

  static const loadErrorDetail =
      'The API could not be reached. Cached todos will appear here when available.';
  static const deleteTaskConfirmation =
      'This task will be removed from your list.';
  static const logOutConfirmation =
      'You can sign back in with the demo credentials.';
}
