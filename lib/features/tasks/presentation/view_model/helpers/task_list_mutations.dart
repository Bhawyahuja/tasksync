import '../../../domain/entities/task.dart';

extension TaskListMutations on List<Task> {
  List<Task> withAdded(Task task) {
    return <Task>[task, ...this];
  }

  List<Task> withUpdated(Task updatedTask) {
    return map((task) {
      return task.id == updatedTask.id ? updatedTask : task;
    }).toList(growable: false);
  }

  List<Task> without(Task removedTask) {
    return where((task) => task.id != removedTask.id).toList(growable: false);
  }
}
