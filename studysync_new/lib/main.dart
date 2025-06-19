import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
//import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart'; // Import for DateFormat
import 'login_page.dart'; // Import the LoginPage
import 'models/task_model.dart'; // Import the Task model

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register the TaskAdapter for the Task model
  Hive.registerAdapter(TaskAdapter());

  // Open the 'uploads' box and add test user if not present
  var uploadsBox = await Hive.openBox('uploads');
  if (!uploadsBox.containsKey('test@example.com')) {
    uploadsBox.put('test@example.com', 'password123');
    print('Added test user: test@example.com');
  }

  // Open the 'tasks' box for TaskManager
  await Hive.openBox<Task>('tasks');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StudySync',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        fontFamily: 'Poppins',
      ),
      home: const LoginPage(), // Kept as LoginPage per your request
    );
  }
}

class TaskManager extends StatefulWidget {
  @override
  _TaskManagerState createState() => _TaskManagerState();
}

class _TaskManagerState extends State<TaskManager> {
  DateTime dueDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Manager'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: Text(
              'Due Date: ${DateFormat('MMM dd, yyyy').format(dueDate)}',
              style: const TextStyle(fontFamily: 'Poppins'),
            ),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: dueDate,
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Colors.deepPurple, // Header background color
                        onPrimary: Colors.white, // Header text color
                        onSurface: Colors.black, // Body text color
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.deepPurple, // Button text color
                        ),
                      ),
                    ),
                    child: child!,
                  );
                },
              );

              if (pickedDate != null && pickedDate != dueDate) {
                setState(() {
                  dueDate = pickedDate;
                });
              }
            },
          ),
        ],
      ),
    );
  }
}