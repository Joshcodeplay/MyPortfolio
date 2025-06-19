import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'models/task_model.dart';

class TaskManager extends StatefulWidget {
  const TaskManager({super.key});

  @override
  State<TaskManager> createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  late Box<Task> _taskBox;
  final List<String> _categories = ['General', 'Homework', 'Exam Prep', 'Project', 'Reading'];
  String _currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    _taskBox = Hive.box<Task>('tasks');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tasks',
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            fontFamily: 'Poppins',
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 10,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterChips(),
          _buildTaskList(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Study Tasks',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Poppins',
              color: Colors.deepPurple[800],
            ),
          ),
          IconButton(
            icon: Icon(Icons.add_circle, color: Colors.deepPurple, size: 32),
            onPressed: _showAddTaskDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        children: ['All', ..._categories].map((category) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: FilterChip(
              label: Text(category),
              selected: _currentFilter == category,
              onSelected: (selected) {
                setState(() {
                  _currentFilter = selected ? category : 'All';
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Colors.deepPurple[200],
              labelStyle: TextStyle(
                fontFamily: 'Poppins',
                color: _currentFilter == category ? Colors.deepPurple : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTaskList() {
    return Expanded(
      child: ValueListenableBuilder(
        valueListenable: _taskBox.listenable(),
        builder: (context, Box<Task> box, _) {
          final tasks = box.values.toList()
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          
          final filteredTasks = _currentFilter == 'All'
              ? tasks
              : tasks.where((task) => task.category == _currentFilter).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.assignment, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    _currentFilter == 'All'
                        ? 'No tasks yet!\nAdd your first study task.'
                        : 'No tasks in this category.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16), // Fixed 'custom' parameter
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              final task = filteredTasks[index];
              return _buildTaskItem(task);
            },
          );
        },
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Slidable(
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          children: [
            SlidableAction(
              onPressed: (context) => _deleteTask(task),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (value) => _toggleTaskCompletion(task, value!),
                      fillColor: WidgetStateProperty.resolveWith<Color>(
                        (states) => task.isCompleted ? Colors.green : Colors.deepPurple,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted 
                              ? TextDecoration.lineThrough 
                              : TextDecoration.none,
                          color: task.isCompleted 
                              ? Colors.grey 
                              : Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(task.category),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.category,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                if (task.description != null && task.description!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 48, top: 8),
                    child: Text(
                      task.description!,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 48, top: 12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 16,
                        color: _getDateColor(task.dueDate, task.isCompleted),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('MMM dd, yyyy').format(task.dueDate),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: _getDateColor(task.dueDate, task.isCompleted),
                        ),
                      ),
                      if (task.dueDate.isBefore(DateTime.now()) && !task.isCompleted)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            '(Overdue)',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              color: Colors.red,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Homework':
        return Colors.blue;
      case 'Exam Prep':
        return Colors.red;
      case 'Project':
        return Colors.purple;
      case 'Reading':
        return Colors.green;
      default:
        return Colors.deepPurple;
    }
  }

  Color _getDateColor(DateTime date, bool isCompleted) {
    if (isCompleted) return Colors.grey;
    if (date.isBefore(DateTime.now())) return Colors.red;
    if (date.isBefore(DateTime.now().add(const Duration(days: 3)))) return Colors.orange;
    return Colors.grey[700]!;
  }

  void _showAddTaskDialog() {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 1));
    String selectedCategory = 'General';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Add New Task',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title*',
                        labelStyle: const TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        labelStyle: const TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      items: _categories.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Category',
                        labelStyle: const TextStyle(fontFamily: 'Poppins'),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(
                        'Due Date: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
                        style: const TextStyle(fontFamily: 'Poppins'),
                      ),
                      trailing: const Icon(Icons.edit),
                      onTap: () {
                        showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        ).then((date) {
                          if (date != null) {
                            setState(() {
                              dueDate = date;
                            });
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (titleController.text.isEmpty) return;
                    
                    final newTask = Task(
                      title: titleController.text,
                      description: descController.text,
                      dueDate: dueDate,
                      category: selectedCategory,
                    );
                    
                    _taskBox.add(newTask);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add Task',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _toggleTaskCompletion(Task task, bool value) {
    setState(() {
      task.isCompleted = value;
      final index = _taskBox.values.toList().indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _taskBox.putAt(index, task); // Update task in Hive
      }
    });
  }

  void _deleteTask(Task task) {
    final index = _taskBox.values.toList().indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _taskBox.deleteAt(index); 
    }
  }
}