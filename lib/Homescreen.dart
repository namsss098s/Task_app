import 'package:final_exam/AuthScreen.dart';
import 'package:final_exam/TaskForm.dart';
import 'package:final_exam/TaskHabitProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedDayIndex = 0;
  int _currentIndex = 0;
  String _selectedTag = 'All';
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final taskProvider = Provider.of<TaskHabitProvider>(context, listen: false);
    taskProvider.fetchTasks(); // Fetch tasks initially
    taskProvider.fetchTags();  // Lấy danh sách tag

  }

  void _onDaySelected(int index) {
    setState(() {
      _selectedDayIndex = index;
    });

    final taskProvider = Provider.of<TaskHabitProvider>(context, listen: false);
    final selectedDate = DateTime(DateTime.now().year, DateTime.now().month, index + 1);
    taskProvider.updateSelectedDate(selectedDate);
    _scrollToSelectedDay();
  }

  void _scrollToSelectedDay() {
    if (_scrollController.hasClients) {
      final itemWidth = 50.0; // Width of each day
      final targetScrollPosition = itemWidth * _selectedDayIndex;

      // Ensure the target position is within scrollable bounds
      final clampedScrollPosition = targetScrollPosition.clamp(
        0.0,
        _scrollController.position.maxScrollExtent,
      );

      _scrollController.animateTo(
        clampedScrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showFilterDialog() {
    final taskProvider = Provider.of<TaskHabitProvider>(context, listen: false);
    final tags = ['All', ...taskProvider.tags]; // Include an "All" filter
    String selectedFilter = _selectedTag; // Currently selected tag
    int selectedTabIndex = taskProvider.selectedTabIndex; // Currently selected status tab

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Filter Options"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Filter by Tag
                    const Text("Filter by Tag:"),
                    Wrap(
                      spacing: 8,
                      children: tags.map((tag) {
                        return ChoiceChip(
                          label: Text(tag),
                          selected: selectedFilter == tag,
                          onSelected: (selected) {
                            setState(() {
                              selectedFilter = tag; // Update selection state
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Filter by Status
                    const Text("Filter by Status:"),
                    Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: const Text("All"),
                          selected: selectedTabIndex == 0,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 0; // Update selection state
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Not Started"),
                          selected: selectedTabIndex == 1,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 1; // Update selection state
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text("In Progress"),
                          selected: selectedTabIndex == 2,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 2; // Update selection state
                              });
                            }
                          },
                        ),
                        ChoiceChip(
                          label: const Text("Completed"),
                          selected: selectedTabIndex == 3,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                selectedTabIndex = 3; // Update selection state
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                // Cancel Button
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Cancel"),
                ),

                // Apply Button
                TextButton(
                  onPressed: () {
                    // Update filters
                    _selectedTag = selectedFilter;
                    taskProvider.updateSelectedTag(selectedFilter);
                    taskProvider.updateSelectedTabIndex(selectedTabIndex);
                    Navigator.of(context).pop();
                  },
                  child: const Text("Apply"),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _onBottomNavTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    switch (index) {
      case 1:
        Navigator.of(context).pushNamed('/tasks');
        break;
      case 2:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskHabitProvider>(context);
    final daysInMonth = taskProvider.getDaysInCurrentMonth();
    final List<String> tags = ['All', ...taskProvider.tags];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[100],
        title: const Text('Task & Habit Manager', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () async {
              DateTime? selectedDate = await showDatePicker(
                context: context,
                initialDate: taskProvider.selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (selectedDate != null) {
                taskProvider.updateSelectedDate(selectedDate);
                _onDaySelected(selectedDate.day - 1);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => Authscreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: _showFilterDialog, // Gọi hộp thoại filter
          ),
        ],
        elevation: 0,
      ),
      body: Column(
        children: [
          // Lọc ngày
          Container(
            color: Colors.purple[100],
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: SizedBox(
              height: 80,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: daysInMonth,
                itemBuilder: (context, index) {
                  final date = DateTime(DateTime.now().year, DateTime.now().month, index + 1);
                  final isSelected = index == _selectedDayIndex;
                  final isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;

                  return GestureDetector(
                    onTap: () {
                      _onDaySelected(index);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        children: [
                          Text(
                            DateFormat('EEE').format(date),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected || isToday ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: isToday
                                ? Colors.orange
                                : isSelected
                                ? Colors.cyan
                                : Colors.grey[200],
                            child: Text(
                              DateFormat('dd').format(date),
                              style: TextStyle(
                                color: isSelected || isToday ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Tìm kiếm task
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              onChanged: (value) {
                taskProvider.updateSearchQuery(value);
              },
              decoration: const InputDecoration(
                hintText: "Search something...",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // Danh sách task
          Expanded(
            child: taskProvider.filteredTasks.isEmpty
                ? const Center(
              child: Text(
                'No task here. Add a new one!',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: taskProvider.filteredTasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.filteredTasks[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    leading: PopupMenuButton<String>(
                      onSelected: (String newStatus) {
                        taskProvider.updateTaskStatus(task.id, newStatus);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'Not Started',
                          child: Row(
                            children: [
                              Icon(
                                Icons.pause_circle_outline,
                                color: task.status == 'Not Started' ? Colors.blue : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text('Not Started'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'In Progress',
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                color: task.status == 'In Progress' ? Colors.orange : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text('In Progress'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Completed',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: task.status == 'Completed' ? Colors.green : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              const Text('Completed'),
                            ],
                          ),
                        ),
                      ],
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: task.status == 'Completed'
                              ? Colors.green
                              : task.status == 'In Progress'
                              ? Colors.orange
                              : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.grey.shade400,
                            width: 2,
                          ),
                        ),
                        child: task.status == 'Completed'
                            ? const Icon(Icons.check, size: 18, color: Colors.white)
                            : task.status == 'In Progress'
                            ? const Icon(Icons.play_arrow, size: 18, color: Colors.white)
                            : null,
                      ),
                    ),

                    title: Text(
                      task.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Priority: ${task.priority}'),
                        if (task.description.isNotEmpty) Text('Description: ${task.description}'),
                        if (task.repeat.isNotEmpty) Text('Repeat: ${task.repeat}'),
                        Text(
                          'Status: ${task.status}',
                          style: TextStyle(
                            color: task.status == 'Completed' ? Colors.green : Colors.redAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => TaskForm()));
        },
        backgroundColor: Colors.purple[200],
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Task'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.grey,
      ),
    );
  }
}
