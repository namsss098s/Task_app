import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'Model.dart';

class TaskHabitProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  List<String> _tags = [];
  DateTime _selectedDate = DateTime.now();
  String _searchQuery = "";
  int _selectedTabIndex = 0; // 0: All, 1: Not Started, 2: In Progress, 3: Completed
  String _selectedTag = 'All';

  List<Task> get filteredTasks => _filteredTasks;
  List<String> get tags => _tags;
  DateTime get selectedDate => _selectedDate;
  String get searchQuery => _searchQuery;
  int get selectedTabIndex => _selectedTabIndex;

  // Fetch tasks from Firebase
  Future<void> fetchTasks() async {
    final databaseReference = FirebaseDatabase.instance.ref("tasks");

    DatabaseEvent event = await databaseReference.once();
    var data = event.snapshot.value;

    if (data != null && data is Map) {
      _tasks = [];
      Map<String, dynamic> tasksMap = Map<String, dynamic>.from(data);

      tasksMap.forEach((key, value) {
        _tasks.add(Task.fromJson({
          'id': key,
          ...Map<String, dynamic>.from(value),
        }));
      });

      _applyFilters();
      notifyListeners();
    }
  }

  // Fetch tags from Firebase
  Future<void> fetchTags() async {
    final databaseReference = FirebaseDatabase.instance.ref("tags");

    databaseReference.onValue.listen((event) {
      var data = event.snapshot.value;

      if (data != null && data is Map) {
        _tags = [];
        Map<String, dynamic> tagsMap = Map<String, dynamic>.from(data);

        tagsMap.forEach((key, value) {
          if (value is String) {
            _tags.add(value);
          }
        });

        notifyListeners();
      }
    });
  }

  // Add a new tag
  Future<void> addNewTag(String tag) async {
    if (_tags.contains(tag)) return;

    final databaseReference = FirebaseDatabase.instance.ref("tags");
    await databaseReference.push().set(tag);
  }

  // Update selected date
  void updateSelectedDate(DateTime selectedDate) {
    _selectedDate = selectedDate;
    _applyFilters();
  }

  // Update search query
  void updateSearchQuery(String searchQuery) {
    _searchQuery = searchQuery;
    _applyFilters();
  }

  // Update selected tab index
  void updateSelectedTabIndex(int index) {
    _selectedTabIndex = index;
    _applyFilters();
  }

  // Apply filters to tasks
  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      // Date conditions
      final currentDate = _selectedDate;
      final currentWeekday = DateFormat('EEE').format(currentDate); // 'Mon', 'Tue', etc.

      // Match repeat type
      bool isMatchingRepeat = false;

      switch (task.repeat) {
        case 'Daily':
          isMatchingRepeat = true;
          break;
        case 'Weekly':
          isMatchingRepeat = task.repeatDays?.contains(currentWeekday) ?? false;
          break;
        case 'Monthly':
          // final taskDate = DateTime.parse(task.repeatDate!); // Ensure `repeatDate` exists for monthly tasks
          // isMatchingRepeat = taskDate.day == currentDate.day;
          break;
      }

      // Search filtering
      bool isMatchingSearch = task.name.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status filtering
      bool isMatchingTab = _selectedTabIndex == 0 || // All
          (_selectedTabIndex == 1 && task.status == 'Not Started') ||
          (_selectedTabIndex == 2 && task.status == 'In Progress') ||
          (_selectedTabIndex == 3 && task.status == 'Completed');

      // Tag filtering
      bool isMatchingTag = _selectedTag == 'All' || task.tag == _selectedTag;

      return isMatchingRepeat && isMatchingSearch && isMatchingTab && isMatchingTag;
    }).toList();

    notifyListeners();
  }

  // Update selected tag and reapply filters
  void updateSelectedTag(String tag) {
    _selectedTag = tag;
    _applyFilters();
  }

  // Add a new task
  Future<void> addTask(Task task) async {
    final databaseReference = FirebaseDatabase.instance.ref("tasks");
    final newTaskRef = databaseReference.push();
    task.id = newTaskRef.key!; // Assign a unique ID
    await newTaskRef.set(task.toJson());
    fetchTasks();
  }

  // Update task status
  Future<void> updateTaskStatus(String id, String newStatus) async {
    final databaseReference = FirebaseDatabase.instance.ref("tasks/$id");
    await databaseReference.update({'status': newStatus});
    fetchTasks();
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    await FirebaseDatabase.instance.ref('tasks/$taskId').remove();
    _tasks.removeWhere((task) => task.id == taskId);
    _applyFilters();
  }

  // Get color based on priority
  Color getPriorityColor(String priority) {
    switch (priority) {
      case 'Low':
        return const Color(0xFF4CAF50);
      case 'Medium':
        return const Color(0xFFFFC107);
      case 'High':
        return const Color(0xFFFF5722);
      default:
        return const Color(0xFF3D748D);
    }
  }

  int getDaysInCurrentMonth() {
    final now = DateTime.now();
    final firstDayOfNextMonth = DateTime(now.year, now.month + 1, 1);
    return firstDayOfNextMonth.subtract(const Duration(days: 1)).day;
  }
}
