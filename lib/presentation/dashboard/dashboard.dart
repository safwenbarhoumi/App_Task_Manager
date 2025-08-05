import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/ai_suggestions_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/greeting_header_widget.dart';
import './widgets/progress_overview_widget.dart';
import './widgets/task_card_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isRefreshing = false;
  int _currentBottomNavIndex = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Sophie Martin',
    'avatar':
        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150&h=150&fit=crop&crop=face',
  };

  // Mock tasks data
  final List<Map<String, dynamic>> _todayTasks = [
    {
      'id': 1,
      'title': 'Review quarterly budget report',
      'description':
          'Analyze Q3 financial performance and prepare recommendations for Q4 budget allocation',
      'category': 'Work',
      'priority': 'High',
      'dueDate': '2025-08-03T16:00:00.000Z',
      'isCompleted': false,
    },
    {
      'id': 2,
      'title': 'Team standup meeting',
      'description':
          'Weekly sync with development team to discuss sprint progress and blockers',
      'category': 'Work',
      'priority': 'Medium',
      'dueDate': '2025-08-03T10:30:00.000Z',
      'isCompleted': false,
    },
    {
      'id': 3,
      'title': 'Grocery shopping',
      'description':
          'Buy ingredients for weekend dinner party - check the shopping list in notes',
      'category': 'Personal',
      'priority': 'Low',
      'dueDate': '2025-08-03T18:00:00.000Z',
      'isCompleted': false,
    },
    {
      'id': 4,
      'title': 'Complete Flutter course module',
      'description':
          'Finish the state management chapter and complete the practice exercises',
      'category': 'Education',
      'priority': 'Medium',
      'dueDate': '2025-08-03T20:00:00.000Z',
      'isCompleted': true,
    },
  ];

  // Mock AI suggestions data
  final List<Map<String, dynamic>> _aiSuggestions = [
    {
      'type': 'schedule',
      'title': 'Optimize your morning routine',
      'description':
          'Based on your patterns, consider scheduling important tasks between 9-11 AM for better focus',
      'confidence': 0.85,
    },
    {
      'type': 'priority',
      'title': 'Review overdue tasks',
      'description':
          'You have 2 tasks from yesterday that might need attention or rescheduling',
      'confidence': 0.92,
    },
    {
      'type': 'productivity',
      'title': 'Take a break reminder',
      'description':
          'You\'ve been productive for 2 hours. Consider a 15-minute break to maintain focus',
      'confidence': 0.78,
    },
  ];

  // Mock progress data
  final Map<String, dynamic> _progressData = {
    'completedTasks': 12,
    'totalTasks': 18,
    'weeklyData': [
      {'day': 'Mon', 'completed': 3},
      {'day': 'Tue', 'completed': 5},
      {'day': 'Wed', 'completed': 2},
      {'day': 'Thu', 'completed': 4},
      {'day': 'Fri', 'completed': 6},
      {'day': 'Sat', 'completed': 1},
      {'day': 'Sun', 'completed': 2},
    ],
  };

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));
    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tasks refreshed successfully'),
          backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _navigateToTaskCreation() {
    Navigator.pushNamed(context, '/task-creation');
  }

  void _navigateToSearch() {
    Navigator.pushNamed(context, '/task-list');
  }

  void _navigateToTaskDetail(Map<String, dynamic> task) {
    Navigator.pushNamed(
      context,
      '/task-detail',
      arguments: task,
    );
  }

  void _handleTaskComplete(Map<String, dynamic> task) {
    setState(() {
      final index = _todayTasks.indexWhere((t) => t['id'] == task['id']);
      if (index != -1) {
        _todayTasks[index]['isCompleted'] =
            !(_todayTasks[index]['isCompleted'] as bool);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          task['isCompleted']
              ? 'Task marked as incomplete'
              : 'Task completed! Great job! 🎉',
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTaskEdit(Map<String, dynamic> task) {
    Navigator.pushNamed(
      context,
      '/task-creation',
      arguments: task,
    );
  }

  void _handleTaskDelete(Map<String, dynamic> task) {
    setState(() {
      _todayTasks.removeWhere((t) => t['id'] == task['id']);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task deleted'),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _todayTasks.add(task);
            });
          },
        ),
      ),
    );
  }

  void _handleTaskDuplicate(Map<String, dynamic> task) {
    final duplicatedTask = Map<String, dynamic>.from(task);
    duplicatedTask['id'] = DateTime.now().millisecondsSinceEpoch;
    duplicatedTask['title'] = '${task['title']} (Copy)';
    duplicatedTask['isCompleted'] = false;

    setState(() {
      _todayTasks.add(duplicatedTask);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Task duplicated'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleTaskShare(Map<String, dynamic> task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing: ${task['title']}'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _handleSuggestionTap(Map<String, dynamic> suggestion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(suggestion['title'] as String),
        content: Text(suggestion['description'] as String),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Suggestion applied!'),
                  backgroundColor: AppTheme.lightTheme.colorScheme.tertiary,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _handleBottomNavTap(int index) {
    setState(() {
      _currentBottomNavIndex = index;
    });

    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        Navigator.pushNamed(context, '/task-list');
        break;
      case 2:
        Navigator.pushNamed(context, '/calendar-view');
        break;
      case 3:
        Navigator.pushNamed(context, '/statistics-dashboard');
        break;
    }
  }

  List<Map<String, dynamic>> get _incompleteTasks =>
      _todayTasks.where((task) => !(task['isCompleted'] as bool)).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppTheme.lightTheme.colorScheme.primary,
          backgroundColor: AppTheme.lightTheme.colorScheme.surface,
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverToBoxAdapter(
                child: GreetingHeaderWidget(
                  userName: _userData['name'] as String,
                  userAvatarUrl: _userData['avatar'] as String,
                  onSearchTap: _navigateToSearch,
                  notificationCount: 3,
                ),
              ),
              if (_isRefreshing)
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.all(4.w),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.lightTheme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              if (_incompleteTasks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    child: Row(
                      children: [
                        Text(
                          'Today\'s Tasks',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        const Spacer(),
                        Text(
                          '${_incompleteTasks.length} remaining',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.lightTheme.colorScheme.onSurface
                                    .withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = _incompleteTasks[index];
                      return TaskCardWidget(
                        task: task,
                        onTap: () => _navigateToTaskDetail(task),
                        onComplete: () => _handleTaskComplete(task),
                        onEdit: () => _handleTaskEdit(task),
                        onDelete: () => _handleTaskDelete(task),
                        onDuplicate: () => _handleTaskDuplicate(task),
                        onShare: () => _handleTaskShare(task),
                      );
                    },
                    childCount: _incompleteTasks.length,
                  ),
                ),
              ] else ...[
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateWidget(
                    onAddTask: _navigateToTaskCreation,
                  ),
                ),
              ],
              if (_incompleteTasks.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: AiSuggestionsWidget(
                    suggestions: _aiSuggestions,
                    onSuggestionTap: _handleSuggestionTap,
                    onViewAll: () =>
                        Navigator.pushNamed(context, '/statistics-dashboard'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: ProgressOverviewWidget(
                    progressData: _progressData,
                    onViewDetails: () =>
                        Navigator.pushNamed(context, '/statistics-dashboard'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(height: 10.h),
                ),
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _navigateToTaskCreation,
              backgroundColor: AppTheme.lightTheme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              icon: CustomIconWidget(
                iconName: 'add',
                color: Colors.white,
                size: 24,
              ),
              label: Text(
                'Quick Add',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color:
                  AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentBottomNavIndex,
            onTap: _handleBottomNavTap,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppTheme.lightTheme.colorScheme.primary,
            unselectedItemColor: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
            items: [
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'dashboard',
                  color: _currentBottomNavIndex == 0
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 24,
                ),
                label: 'Today',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'list_alt',
                  color: _currentBottomNavIndex == 1
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 24,
                ),
                label: 'Tasks',
              ),
              BottomNavigationBarItem(
                icon: CustomIconWidget(
                  iconName: 'calendar_today',
                  color: _currentBottomNavIndex == 2
                      ? AppTheme.lightTheme.colorScheme.primary
                      : AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.6),
                  size: 24,
                ),
                label: 'Calendar',
              ),
              BottomNavigationBarItem(
                icon: Stack(
                  children: [
                    CustomIconWidget(
                      iconName: 'more_horiz',
                      color: _currentBottomNavIndex == 3
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                      size: 24,
                    ),
                    if (_aiSuggestions.isNotEmpty)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          width: 2.w,
                          height: 2.w,
                          decoration: BoxDecoration(
                            color: AppTheme.lightTheme.colorScheme.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
                label: 'More',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
