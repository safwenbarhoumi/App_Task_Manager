import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/calendar_header_widget.dart';
import './widgets/day_detail_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/month_calendar_widget.dart';
import './widgets/week_calendar_widget.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({super.key});

  @override
  State<CalendarView> createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView>
    with TickerProviderStateMixin {
  DateTime _currentDate = DateTime.now();
  DateTime? _selectedDate;
  bool _isWeekView = false;
  bool _isLoading = false;
  bool _isOffline = false;
  Set<String> _visibleCategories = {
    'Work',
    'Personal',
    'Health',
    'Education',
    'Finance',
    'Shopping',
    'Travel',
    'General'
  };
  Set<String> _visiblePriorities = {'High', 'Medium', 'Low'};

  late AnimationController _refreshController;
  late AnimationController _slideController;

  // Mock task data
  final List<Map<String, dynamic>> _tasks = [
    {
      "id": 1,
      "title": "Team Meeting",
      "description":
          "Weekly team sync to discuss project progress and upcoming deadlines",
      "category": "Work",
      "priority": "high",
      "isCompleted": false,
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "startTime": DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 9, minute: 0),
      "duration": 60,
      "tags": ["meeting", "team", "sync"],
    },
    {
      "id": 2,
      "title": "Doctor Appointment",
      "description": "Annual health checkup with Dr. Smith",
      "category": "Health",
      "priority": "medium",
      "isCompleted": false,
      "dueDate": DateTime.now().add(const Duration(days: 2)),
      "startTime": DateTime.now()
          .add(const Duration(days: 2))
          .copyWith(hour: 14, minute: 30),
      "duration": 45,
      "tags": ["health", "appointment"],
    },
    {
      "id": 3,
      "title": "Grocery Shopping",
      "description": "Buy ingredients for weekend dinner party",
      "category": "Shopping",
      "priority": "low",
      "isCompleted": false,
      "dueDate": DateTime.now(),
      "startTime": DateTime.now().copyWith(hour: 16, minute: 0),
      "duration": 90,
      "tags": ["shopping", "groceries"],
    },
    {
      "id": 4,
      "title": "Project Presentation",
      "description": "Present Q4 results to stakeholders",
      "category": "Work",
      "priority": "high",
      "isCompleted": false,
      "dueDate": DateTime.now().add(const Duration(days: 3)),
      "startTime": DateTime.now()
          .add(const Duration(days: 3))
          .copyWith(hour: 10, minute: 0),
      "duration": 120,
      "tags": ["presentation", "work", "quarterly"],
    },
    {
      "id": 5,
      "title": "Study Session",
      "description": "Review Flutter development concepts",
      "category": "Education",
      "priority": "medium",
      "isCompleted": true,
      "dueDate": DateTime.now().subtract(const Duration(days: 1)),
      "startTime": DateTime.now()
          .subtract(const Duration(days: 1))
          .copyWith(hour: 19, minute: 0),
      "duration": 120,
      "tags": ["study", "flutter", "development"],
    },
    {
      "id": 6,
      "title": "Budget Review",
      "description": "Monthly financial planning and expense tracking",
      "category": "Finance",
      "priority": "medium",
      "isCompleted": false,
      "dueDate": DateTime.now().add(const Duration(days: 5)),
      "startTime": DateTime.now()
          .add(const Duration(days: 5))
          .copyWith(hour: 20, minute: 0),
      "duration": 60,
      "tags": ["finance", "budget", "planning"],
    },
    {
      "id": 7,
      "title": "Workout Session",
      "description": "Cardio and strength training at the gym",
      "category": "Health",
      "priority": "medium",
      "isCompleted": false,
      "dueDate": DateTime.now().add(const Duration(days: 1)),
      "startTime": DateTime.now()
          .add(const Duration(days: 1))
          .copyWith(hour: 7, minute: 0),
      "duration": 75,
      "tags": ["fitness", "health", "gym"],
    },
    {
      "id": 8,
      "title": "Call Mom",
      "description": "Weekly catch-up call with family",
      "category": "Personal",
      "priority": "low",
      "isCompleted": false,
      "dueDate": DateTime.now(),
      "startTime": DateTime.now().copyWith(hour: 18, minute: 30),
      "duration": 30,
      "tags": ["family", "personal", "call"],
    },
  ];

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _checkConnectivity();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    // Simulate connectivity check
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isOffline = false; // Assume online for demo
    });
  }

  Future<void> _refreshCalendar() async {
    setState(() {
      _isLoading = true;
    });

    _refreshController.forward();

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    _refreshController.reset();
    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isOffline ? 'Showing cached data' : 'Calendar updated',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
          ),
          backgroundColor: _isOffline
              ? AppTheme.lightTheme.colorScheme.secondary
              : AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }
  }

  void _toggleView() {
    setState(() {
      _isWeekView = !_isWeekView;
      _selectedDate = null;
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
      _selectedDate = null;
    });
  }

  void _navigateToPreviousPeriod() {
    setState(() {
      if (_isWeekView) {
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1, 1);
      }
      _selectedDate = null;
    });
  }

  void _navigateToNextPeriod() {
    setState(() {
      if (_isWeekView) {
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else {
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1, 1);
      }
      _selectedDate = null;
    });
  }

  void _onDateTap(DateTime date) {
    setState(() {
      _selectedDate = date;
    });

    final dayTasks = _getTasksForDate(date);
    if (dayTasks.isNotEmpty || _selectedDate != null) {
      _showDayDetail(date, dayTasks);
    }
  }

  void _onTaskTap(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-detail', arguments: task);
  }

  void _onTaskComplete(Map<String, dynamic> task) {
    setState(() {
      final index = _tasks.indexWhere((t) => t['id'] == task['id']);
      if (index != -1) {
        _tasks[index]['isCompleted'] = !(task['isCompleted'] as bool? ?? false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task['isCompleted'] as bool? ?? false
              ? 'Task marked as incomplete'
              : 'Task completed!',
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onTaskEdit(Map<String, dynamic> task) {
    Navigator.pushNamed(context, '/task-creation', arguments: task);
  }

  void _onLongPress(DateTime dateTime) {
    _showQuickAddDialog(dateTime);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        selectedCategories: _visibleCategories,
        selectedPriorities: _visiblePriorities,
        onFiltersChanged: (categories, priorities) {
          setState(() {
            _visibleCategories = categories;
            _visiblePriorities = priorities;
          });
        },
      ),
    );
  }

  void _showDayDetail(DateTime date, List<Map<String, dynamic>> dayTasks) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailWidget(
        selectedDate: date,
        dayTasks: dayTasks,
        onTaskTap: _onTaskTap,
        onTaskComplete: _onTaskComplete,
        onTaskEdit: _onTaskEdit,
        onAddTask: () {
          Navigator.pop(context);
          _showQuickAddDialog(date);
        },
        visibleCategories: _visibleCategories,
      ),
    );
  }

  void _showQuickAddDialog(DateTime dateTime) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Quick Add Task',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add a new task for ${_formatDate(dateTime)}',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/task-creation',
                          arguments: {
                            'dueDate': dateTime,
                            'startTime': dateTime,
                          });
                    },
                    icon: CustomIconWidget(
                      iconName: 'add_task',
                      color: Colors.white,
                      size: 18,
                    ),
                    label: const Text('Create Task'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getTasksForDate(DateTime date) {
    return _tasks.where((task) {
      final dueDate = task['dueDate'] as DateTime?;
      if (dueDate == null) return false;

      return dueDate.year == date.year &&
          dueDate.month == date.month &&
          dueDate.day == date.day;
    }).toList();
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Calendar',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 0,
        actions: [
          if (_isOffline)
            Container(
              margin: EdgeInsets.only(right: 2.w),
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.secondary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'cloud_off',
                    color: AppTheme.lightTheme.colorScheme.secondary,
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    'Offline',
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.secondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/task-creation'),
            icon: CustomIconWidget(
              iconName: 'add',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCalendar,
        color: AppTheme.lightTheme.colorScheme.primary,
        child: Column(
          children: [
            CalendarHeaderWidget(
              currentDate: _currentDate,
              isWeekView: _isWeekView,
              onToggleView: _toggleView,
              onTodayPressed: _goToToday,
              onPreviousPeriod: _navigateToPreviousPeriod,
              onNextPeriod: _navigateToNextPeriod,
              onFilterPressed: _showFilterBottomSheet,
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Syncing calendar...',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                    )
                  : _isWeekView
                      ? WeekCalendarWidget(
                          currentDate: _currentDate,
                          tasks: _tasks,
                          onDateTap: _onDateTap,
                          onTaskTap: _onTaskTap,
                          onLongPress: _onLongPress,
                          visibleCategories: _visibleCategories,
                        )
                      : MonthCalendarWidget(
                          currentDate: _currentDate,
                          tasks: _tasks,
                          onDateTap: _onDateTap,
                          onTaskTap: _onTaskTap,
                          visibleCategories: _visibleCategories,
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 3, // Calendar tab index
        selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
        unselectedItemColor:
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
        backgroundColor: AppTheme.lightTheme.colorScheme.surface,
        elevation: 8,
        items: [
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'dashboard',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'dashboard',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'add_task',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'add_task',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Create',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'list_alt',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'list_alt',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Tasks',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'calendar_today',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
              size: 24,
            ),
            activeIcon: CustomIconWidget(
              iconName: 'analytics',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            label: 'Stats',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.pushNamed(context, '/task-creation');
              break;
            case 2:
              Navigator.pushNamed(context, '/task-list');
              break;
            case 3:
              // Already on calendar view
              break;
            case 4:
              Navigator.pushNamed(context, '/statistics-dashboard');
              break;
          }
        },
      ),
    );
  }
}
