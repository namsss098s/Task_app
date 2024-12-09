import 'package:final_exam/Model.dart';
import 'package:final_exam/TaskHabitProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TaskForm extends StatefulWidget {
  const TaskForm({Key? key}) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _newTagController = TextEditingController();

  String _selectedPriority = "Low";
  String _selectedCycle = "Weekly";
  Set<String> _selectedDays = {};
  String? _selectedTag;

  final Map<String, Color> _priorityColors = {
    "Low": Colors.green,
    "Medium": Colors.orange,
    "High": Colors.red,
    "Urgent": Colors.purple,
    "Normal": Colors.blue,
  };
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskHabitProvider>(context);

    return Scaffold(
      backgroundColor: Colors.pink[50],
      appBar: AppBar(
        title: const Text("New Task"),
        backgroundColor: Colors.pink[100],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Name
              TextFormField(
                controller: _taskNameController,
                decoration: const InputDecoration(labelText: "Task Name"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Task name is required";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Task Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: "Description"),
              ),
              const SizedBox(height: 20),

              // Priority Selection
              const Text("Priority", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _priorityColors.keys.map((priority) {
                  return ChoiceChip(
                    label: Text(priority),
                    selected: _selectedPriority == priority,
                    selectedColor: _priorityColors[priority],
                    onSelected: (isSelected) {
                      if (isSelected) {
                        setState(() {
                          _selectedPriority = priority;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Repeat Cycle Selection
              const Text("Repeat Cycle", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["Daily", "Weekly", "Monthly"].map((cycle) {
                  return ChoiceChip(
                    label: Text(cycle),
                    selected: _selectedCycle == cycle,
                    onSelected: (isSelected) {
                      if (isSelected) {
                        setState(() {
                          _selectedCycle = cycle;
                        });
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 10),

              // Day Selection for Weekly Cycle
              if (_selectedCycle == "Weekly")
                Wrap(
                  spacing: 8,
                  children: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map((day) {
                    return FilterChip(
                      label: Text(day),
                      selected: _selectedDays.contains(day),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedDays.add(day);
                          } else {
                            _selectedDays.remove(day);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              const SizedBox(height: 20),

              // Tag Selection
              const Text("Tag", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedTag,
                      decoration: const InputDecoration(labelText: "Select a Tag"),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedTag = newValue!;
                        });
                      },
                      items: provider.tags.map((tag) {
                        return DropdownMenuItem(value: tag, child: Text(tag));
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _newTagController,
                      decoration: const InputDecoration(
                        labelText: "Create New Tag",
                        hintText: "Enter new tag",
                      ),
                    ),
                  ),
                  const SizedBox(width: 0),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final newTag = _newTagController.text.trim();
                      if (newTag.isNotEmpty) {
                        await provider.addNewTag(newTag);
                        setState(() {
                          _selectedTag = newTag; // Automatically select the new tag
                        });
                        _newTagController.clear();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Tag '$newTag' added successfully!")),
                        );
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      String tagToUse = _newTagController.text.isNotEmpty
                          ? _newTagController.text
                          : (_selectedTag ?? "Uncategorized");

                      final task = Task(
                        id: '', // ID will be set after the task is added to Firebase
                        name: _taskNameController.text,
                        priority: _selectedPriority,
                        status: "Not Started",
                        description: _descriptionController.text,
                        repeat: _selectedCycle,
                        repeatDays: _selectedCycle == "Weekly" ? _selectedDays : null,
                        tag: tagToUse,
                      );

                      await provider.addTask(task);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Task added successfully!")),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add Task"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
