import 'dart:async';
import 'package:final_exam/TaskForm.dart';
import 'package:final_exam/TaskHabitProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  DateTime _currentDate = DateTime.now();
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    // Update current date every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (Timer t) {
      final now = DateTime.now();
      if (!isSameDay(now, _currentDate)) {
        setState(() {
          _currentDate = now;
        });
      }
    });

    // Fetch tasks when initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskHabitProvider>(context, listen: false).fetchTasks();
    });
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return DateFormat('yyyy-MM-dd').format(date1) ==
        DateFormat('yyyy-MM-dd').format(date2);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskHabitProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Task Manager"),
        backgroundColor: Colors.lightBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: "Add Task",
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const TaskForm()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // Show filter dialog
              _showFilterDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Calendar Section
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.lightBlue[100],
            child: Column(
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(provider.selectedDate),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    final startOfWeek = _currentDate.subtract(
                        Duration(days: _currentDate.weekday - 1));
                    final date = startOfWeek.add(Duration(days: index));
                    final isToday = isSameDay(date, _currentDate);
                    final isSelected = isSameDay(date, provider.selectedDate);

                    return GestureDetector(
                      onTap: () {
                        provider.updateSelectedDate(date);
                      },
                      child: Column(
                        children: [
                          Text(
                            DateFormat('E').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : (isToday ? Colors.orange : Colors.white),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.grey),
                            ),
                            child: Text(
                              isToday ? "Today" : date.day.toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isToday ? Colors.white : Colors.black),
                                fontSize: isToday ? 12 : 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),

          // Task List Section
          Expanded(
            child: Consumer<TaskHabitProvider>(
              builder: (context, provider, child) {
                final filteredTasks = provider.filteredTasks;

                if (filteredTasks.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.task_alt, size: 100, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      const Text(
                        "No tasks for this day.",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const TaskForm()),
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text("Add Task"),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: provider.getPriorityColor(task.priority).withOpacity(0.2),
                          child: Icon(Icons.task, color: provider.getPriorityColor(task.priority)),
                        ),
                        title: Row(
                          children: [
                            // Circular status indicator
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: task.status == "Completed"
                                    ? Colors.green
                                    : task.status == "In Progress"
                                    ? Colors.orange
                                    : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                task.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Dropdown for status selection
                            DropdownButton<String>(
                              value: task.status,
                              items: ["Not Started", "In Progress", "Completed"]
                                  .map((String status) {
                                return DropdownMenuItem<String>(
                                  value: status,
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: status == "Completed"
                                          ? Colors.green
                                          : status == "In Progress"
                                          ? Colors.orange
                                          : Colors.red,
                                    ),
                                  ),
                                );
                              }).toList(),
                              onChanged: (String? newStatus) {
                                if (newStatus != null) {
                                  provider.updateTaskStatus(task.id, newStatus);
                                }
                              },
                            ),

                            // Delete button
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                // Confirm deletion
                                final confirm = await showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Delete Task'),
                                    content:
                                    const Text('Are you sure you want to delete this task?'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(ctx).pop(true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  provider.deleteTask(task.id);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Task "${task.name}" deleted.')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                      )

                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    // Implement your filter dialog here
  }
}
