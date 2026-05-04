import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/task_repository.dart';
import '../../profile/data/user_repository.dart';
import 'task_event.dart';
import 'task_state.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final _taskRepo = TaskRepository();
  final _userRepo = UserRepository();

  TaskBloc() : super(TaskInitial()) {
    on<LoadTasksEvent>(_onLoad);
    on<AddTaskEvent>(_onAdd);
    on<UpdateTaskEvent>(_onUpdate);
    on<CompleteTaskEvent>(_onComplete);
    on<DeleteTaskEvent>(_onDelete);
  }

  Future<void> _onLoad(LoadTasksEvent event, Emitter<TaskState> emit) async {
    emit(TaskLoading());
    try {
      final tasks = await _taskRepo.getAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Не удалось загрузить задачи: $e'));
    }
  }

  Future<void> _onAdd(AddTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _taskRepo.save(event.task);
      final tasks = await _taskRepo.getAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Не удалось добавить задачу: $e'));
    }
  }

  Future<void> _onUpdate(UpdateTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _taskRepo.save(event.task);
      final tasks = await _taskRepo.getAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Не удалось обновить задачу: $e'));
    }
  }

  Future<void> _onComplete(CompleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      final task = await _taskRepo.getById(event.id);
      if (task == null || task.isCompleted) return;

      task.isCompleted = true;
      task.completedAt = DateTime.now();

      int points = task.pointsReward;
      if (task.deadline != null && task.deadline!.isAfter(DateTime.now())) {
        points = (points * 1.25).round();
      }
      if (task.priority == 3) points = (points * 1.2).round();
      if (task.priority == 2) points = (points * 1.1).round();

      await _taskRepo.save(task);
      await _userRepo.addPoints(points);
      await _userRepo.incrementStat('tasks');

      final tasks = await _taskRepo.getAll();
      emit(TaskCompleted(tasks: tasks, pointsEarned: points));
    } catch (e) {
      emit(TaskError('Не удалось выполнить задачу: $e'));
    }
  }

  Future<void> _onDelete(DeleteTaskEvent event, Emitter<TaskState> emit) async {
    try {
      await _taskRepo.delete(event.id);
      final tasks = await _taskRepo.getAll();
      emit(TaskLoaded(tasks));
    } catch (e) {
      emit(TaskError('Не удалось удалить задачу: $e'));
    }
  }
}