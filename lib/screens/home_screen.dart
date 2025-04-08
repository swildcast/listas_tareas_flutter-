import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTasks();
    });
  }

  Future<void> _loadTasks() async {
    try {
      await Provider.of<TaskProvider>(context, listen: false).loadTasks();
    } catch (e) {
      _showError('Error al cargar tareas: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lista de Tareas')),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          if (taskProvider.error != null && taskProvider.tasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    taskProvider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadTasks,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (taskProvider.isLoading && taskProvider.tasks.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _taskController,
                        decoration: const InputDecoration(
                          labelText: 'Nueva tarea',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        if (_taskController.text.isNotEmpty) {
                          try {
                            await taskProvider.addTask(_taskController.text);
                            _taskController.clear();
                            _showSuccess('Tarea agregada');
                          } catch (e) {
                            _showError(
                                'Error al agregar tarea: ${e.toString()}');
                          }
                        }
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (ctx, index) => Dismissible(
                    key: Key(taskProvider.tasks[index].id.toString()),
                    background: Container(color: Colors.red),
                    onDismissed: (direction) async {
                      try {
                        await taskProvider
                            .removeTask(taskProvider.tasks[index].id);
                        _showSuccess('Tarea eliminada');
                      } catch (e) {
                        _showError('Error al eliminar tarea: ${e.toString()}');
                      }
                    },
                    child: CheckboxListTile(
                      title: Text(taskProvider.tasks[index].title),
                      value: taskProvider.tasks[index].completed,
                      onChanged: (_) async {
                        try {
                          await taskProvider
                              .toggleTask(taskProvider.tasks[index].id);
                        } catch (e) {
                          _showError(
                              'Error al actualizar tarea: ${e.toString()}');
                        }
                      },
                    ),
                  ),
                ),
              ),
              if (taskProvider.isLoading && taskProvider.tasks.isNotEmpty)
                const LinearProgressIndicator(),
            ],
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}
