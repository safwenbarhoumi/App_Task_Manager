import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/search_bar_widget.dart';
import './widgets/sort_bottom_sheet_widget.dart';
import './widgets/task_card_widget.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  // State variables
  String _searchQuery = '';
  Map<String, dynamic> _currentFilters = {
    'status': 'all',
    'priorities': <String>[],
    'categories': <String>[],
    'dateFilter': null,
    'assignedUsers': <String>[],
  };
  String _currentSortBy = 'dueDate';
  bool _isAscending = true;
  bool _isMultiSelectMode = false;
  Set<int> _selectedTaskIds = <int>{};
  bool _isLoading = false;
  bool _isOffline = false;

  // Mock data
  List<Map<String, dynamic>> _allTasks = [];
  List<Map<String, dynamic>> _filteredTasks = [];
  List<String> _recentSearches = ['Work tasks', 'High priority', 'This week'];
  List<String> _suggestedTags = [
    'urgent',
    'meeting',
    'review',
    'personal',
    'shopping'
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMockData();
    _setupScrollListener();
  }

  void _initializeAnimations() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
    _fabAnimationController.forward();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 &&
          _fabAnimationController.value == 1.0) {
        _fabAnimationController.reverse();
      } else if (_scrollController.offset <= 100 &&
          _fabAnimationController.value == 0.0) {
        _fabAnimationController.forward();
      }
    });
  }

  void _loadMockData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _allTasks = [
          {
            'id': 1,
            'title': 'Complete project proposal',
            'description':
                'Finalize the Q4 project proposal with budget estimates',
            'isCompleted': false,
            'priority': 'high',
            'category': 'Work',
            'dueDate': DateTime.now().add(const Duration(days: 2)),
            'createdDate': DateTime.now().subtract(const Duration(days: 3)),
            'assignedTo': 'Me',
            'tags': ['urgent', 'proposal'],
          },
          {
            'id': 2,
            'title': 'Team meeting preparation',
            'description': 'Prepare agenda and materials for weekly team sync',
            'isCompleted': false,
            'priority': 'medium',
            'category': 'Work',
            'dueDate': DateTime.now().add(const Duration(days: 1)),
            'createdDate': DateTime.now().subtract(const Duration(days: 2)),
            'assignedTo': 'John Doe',
            'tags': ['meeting', 'team'],
          },
          {
            'id': 3,
            'title': 'Buy groceries',
            'description': 'Weekly grocery shopping - milk, bread, fruits',
            'isCompleted': true,
            'priority': 'low',
            'category': 'Personal',
            'dueDate': DateTime.now().subtract(const Duration(days: 1)),
            'createdDate': DateTime.now().subtract(const Duration(days: 4)),
            'assignedTo': 'Me',
            'tags': ['shopping', 'personal'],
          },
          {
            'id': 4,
            'title': 'Review code changes',
            'description': 'Review pull requests from the development team',
            'isCompleted': false,
            'priority': 'high',
            'category': 'Work',
            'dueDate': DateTime.now(),
            'createdDate': DateTime.now().subtract(const Duration(days: 1)),
            'assignedTo': 'Jane Smith',
            'tags': ['review', 'code'],
          },
          {
            'id': 5,
            'title': 'Doctor appointment',
            'description': 'Annual health checkup at 2 PM',
            'isCompleted': false,
            'priority': 'medium',
            'category': 'Health',
            'dueDate': DateTime.now().add(const Duration(days: 7)),
            'createdDate': DateTime.now().subtract(const Duration(days: 5)),
            'assignedTo': 'Me',
            'tags': ['health', 'appointment'],
          },
          {
            'id': 6,
            'title': 'Update portfolio website',
            'description': 'Add recent projects and update contact information',
            'isCompleted': false,
            'priority': 'low',
            'category': 'Personal',
            'dueDate': DateTime.now().add(const Duration(days: 14)),
            'createdDate': DateTime.now().subtract(const Duration(days: 6)),
            'assignedTo': 'Me',
            'tags': ['portfolio', 'website'],
          },
          {
            'id': 7,
            'title': 'Plan weekend trip',
            'description': 'Research destinations and book accommodations',
            'isCompleted': false,
            'priority': 'low',
            'category': 'Personal',
            'dueDate': DateTime.now().add(const Duration(days: 10)),
            'createdDate': DateTime.now().subtract(const Duration(days: 2)),
            'assignedTo': 'Me',
            'tags': ['travel', 'planning'],
          },
          {
            'id': 8,
            'title': 'Submit expense reports',
            'description': 'Compile and submit Q3 expense reports to finance',
            'isCompleted': true,
            'priority': 'medium',
            'category': 'Work',
            'dueDate': DateTime.now().subtract(const Duration(days: 3)),
            'createdDate': DateTime.now().subtract(const Duration(days: 7)),
            'assignedTo': 'Me',
            'tags': ['finance', 'reports'],
          },
        ];
        _filteredTasks = List.from(_allTasks);
        _isLoading = false;
      });
      _applyFiltersAndSort();
    });
  }

  void _applyFiltersAndSort() {
    setState(() {
      _filteredTasks = _allTasks.where((task) {
        // Search filter
        if (_searchQuery.isNotEmpty) {
          final query = _searchQuery.toLowerCase();
          final title = (task['title'] as String).toLowerCase();
          final description =
              (task['description'] as String? ?? '').toLowerCase();
          final tags =
              (task['tags'] as List<String>? ?? []).join(' ').toLowerCase();

          if (!title.contains(query) &&
              !description.contains(query) &&
              !tags.contains(query.replaceAll('#', ''))) {
            return false;
          }
        }

        // Status filter
        final status = _currentFilters['status'] as String;
        if (status != 'all') {
          final isCompleted = task['isCompleted'] as bool;
          if (status == 'completed' && !isCompleted) return false;
          if (status == 'pending' && isCompleted) return false;
        }

        // Priority filter
        final selectedPriorities =
            _currentFilters['priorities'] as List<String>;
        if (selectedPriorities.isNotEmpty) {
          final taskPriority = task['priority'] as String;
          if (!selectedPriorities.contains(taskPriority)) return false;
        }

        // Category filter
        final selectedCategories =
            _currentFilters['categories'] as List<String>;
        if (selectedCategories.isNotEmpty) {
          final taskCategory = task['category'] as String;
          if (!selectedCategories.contains(taskCategory)) return false;
        }

        // Date filter
        final dateFilter = _currentFilters['dateFilter'] as String?;
        if (dateFilter != null) {
          final dueDate = task['dueDate'] as DateTime?;
          if (dueDate != null) {
            final now = DateTime.now();
            switch (dateFilter) {
              case 'today':
                if (dueDate.day != now.day ||
                    dueDate.month != now.month ||
                    dueDate.year != now.year) return false;
                break;
              case 'tomorrow':
                final tomorrow = now.add(const Duration(days: 1));
                if (dueDate.day != tomorrow.day ||
                    dueDate.month != tomorrow.month ||
                    dueDate.year != tomorrow.year) return false;
                break;
              case 'this_week':
                final weekStart = now.subtract(Duration(days: now.weekday - 1));
                final weekEnd = weekStart.add(const Duration(days: 6));
                if (dueDate.isBefore(weekStart) || dueDate.isAfter(weekEnd))
                  return false;
                break;
              case 'overdue':
                if (!dueDate.isBefore(now)) return false;
                break;
            }
          }
        }

        // Assigned user filter
        final selectedUsers = _currentFilters['assignedUsers'] as List<String>;
        if (selectedUsers.isNotEmpty) {
          final assignedTo = task['assignedTo'] as String;
          if (!selectedUsers.contains(assignedTo)) return false;
        }

        return true;
      }).toList();

      // Apply sorting
      _filteredTasks.sort((a, b) {
        int comparison = 0;

        switch (_currentSortBy) {
          case 'dueDate':
            final aDate = a['dueDate'] as DateTime?;
            final bDate = b['dueDate'] as DateTime?;
            if (aDate == null && bDate == null)
              comparison = 0;
            else if (aDate == null)
              comparison = 1;
            else if (bDate == null)
              comparison = -1;
            else
              comparison = aDate.compareTo(bDate);
            break;
          case 'priority':
            final priorityOrder = {'high': 3, 'medium': 2, 'low': 1};
            final aPriority = priorityOrder[a['priority']] ?? 0;
            final bPriority = priorityOrder[b['priority']] ?? 0;
            comparison =
                bPriority.compareTo(aPriority); // High to low by default
            break;
          case 'createdDate':
            final aDate = a['createdDate'] as DateTime;
            final bDate = b['createdDate'] as DateTime;
            comparison = aDate.compareTo(bDate);
            break;
          case 'title':
            comparison = (a['title'] as String).compareTo(b['title'] as String);
            break;
          case 'category':
            comparison =
                (a['category'] as String).compareTo(b['category'] as String);
            break;
        }

        return _isAscending ? comparison : -comparison;
      });
    });
  }

  bool _hasActiveFilters() {
    return _currentFilters['status'] != 'all' ||
        (_currentFilters['priorities'] as List).isNotEmpty ||
        (_currentFilters['categories'] as List).isNotEmpty ||
        _currentFilters['dateFilter'] != null ||
        (_currentFilters['assignedUsers'] as List).isNotEmpty;
  }

  void _toggleTaskCompletion(int taskId) {
    setState(() {
      final taskIndex = _allTasks.indexWhere((task) => task['id'] == taskId);
      if (taskIndex != -1) {
        _allTasks[taskIndex]['isCompleted'] =
            !(_allTasks[taskIndex]['isCompleted'] as bool);
      }
    });
    _applyFiltersAndSort();
  }

  void _deleteTask(int taskId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text(
            'Are you sure you want to delete this task? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _allTasks.removeWhere((task) => task['id'] == taskId);
              });
              _applyFiltersAndSort();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _toggleMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      if (!_isMultiSelectMode) {
        _selectedTaskIds.clear();
      }
    });
  }

  void _toggleTaskSelection(int taskId) {
    setState(() {
      if (_selectedTaskIds.contains(taskId)) {
        _selectedTaskIds.remove(taskId);
      } else {
        _selectedTaskIds.add(taskId);
      }
    });
  }

  void _performBatchAction(String action) {
    switch (action) {
      case 'complete':
        setState(() {
          for (final taskId in _selectedTaskIds) {
            final taskIndex =
                _allTasks.indexWhere((task) => task['id'] == taskId);
            if (taskIndex != -1) {
              _allTasks[taskIndex]['isCompleted'] = true;
            }
          }
        });
        break;
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Tasks'),
            content: Text(
                'Are you sure you want to delete ${_selectedTaskIds.length} selected tasks?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _allTasks.removeWhere(
                        (task) => _selectedTaskIds.contains(task['id']));
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
    }

    setState(() {
      _selectedTaskIds.clear();
      _isMultiSelectMode = false;
    });
    _applyFiltersAndSort();
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilters = {
        'status': 'all',
        'priorities': <String>[],
        'categories': <String>[],
        'dateFilter': null,
        'assignedUsers': <String>[],
      };
      _searchQuery = '';
    });
    _applyFiltersAndSort();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: _buildAppBar(context),
      body: _buildBody(context),
      floatingActionButton: _buildFloatingActionButton(context),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isMultiSelectMode) {
      return AppBar(
        title: Text('${_selectedTaskIds.length} selected'),
        leading: IconButton(
          onPressed: _toggleMultiSelectMode,
          icon: CustomIconWidget(
            iconName: 'close',
            color: colorScheme.onSurface,
            size: 6.w,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _selectedTaskIds.isNotEmpty
                ? () => _performBatchAction('complete')
                : null,
            icon: CustomIconWidget(
              iconName: 'check_circle',
              color: _selectedTaskIds.isNotEmpty
                  ? Colors.green
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: _selectedTaskIds.isNotEmpty
                ? () => _performBatchAction('delete')
                : null,
            icon: CustomIconWidget(
              iconName: 'delete',
              color: _selectedTaskIds.isNotEmpty
                  ? Colors.red
                  : colorScheme.onSurface.withValues(alpha: 0.4),
              size: 6.w,
            ),
          ),
        ],
      );
    }

    return AppBar(
      title: const Text('Tasks'),
      actions: [
        if (_isOffline)
          Padding(
            padding: EdgeInsets.only(right: 2.w),
            child: CustomIconWidget(
              iconName: 'cloud_off',
              color: Colors.orange,
              size: 6.w,
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        SearchBarWidget(
          searchQuery: _searchQuery,
          onSearchChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
            _applyFiltersAndSort();
          },
          onFilterTap: () => _showFilterBottomSheet(),
          onSortTap: () => _showSortBottomSheet(),
          hasActiveFilters: _hasActiveFilters(),
          recentSearches: _recentSearches,
          suggestedTags: _suggestedTags,
        ),
        Expanded(
          child: _isLoading
              ? _buildLoadingState()
              : _filteredTasks.isEmpty
                  ? _buildEmptyState()
                  : _buildTaskList(),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: colorScheme.primary,
          ),
          SizedBox(height: 2.h),
          Text(
            'Loading tasks...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return TaskEmptyStates.noSearchResults(_searchQuery);
    } else if (_hasActiveFilters()) {
      return TaskEmptyStates.noFilteredTasks(_clearAllFilters);
    } else if (_allTasks.every((task) => task['isCompleted'] as bool)) {
      return TaskEmptyStates.allTasksCompleted(() {
        Navigator.pushNamed(context, '/task-creation');
      });
    } else {
      return TaskEmptyStates.noTasks(() {
        Navigator.pushNamed(context, '/task-creation');
      });
    }
  }

  Widget _buildTaskList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        _loadMockData();
      },
      child: ListView.builder(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          final task = _filteredTasks[index];
          final taskId = task['id'] as int;

          return TaskCardWidget(
            task: task,
            isSelected: _selectedTaskIds.contains(taskId),
            onTap: () {
              if (_isMultiSelectMode) {
                _toggleTaskSelection(taskId);
              } else {
                Navigator.pushNamed(
                  context,
                  '/task-detail',
                  arguments: task,
                );
              }
            },
            onLongPress: () {
              if (!_isMultiSelectMode) {
                _toggleMultiSelectMode();
                _toggleTaskSelection(taskId);
              }
            },
            onToggleComplete: () => _toggleTaskCompletion(taskId),
            onDelete: () => _deleteTask(taskId),
          );
        },
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaleTransition(
      scale: _fabAnimation,
      child: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/task-creation'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 7.w,
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _currentFilters,
        onFiltersChanged: (filters) {
          setState(() {
            _currentFilters = filters;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SortBottomSheetWidget(
        currentSortBy: _currentSortBy,
        isAscending: _isAscending,
        onSortChanged: (sortBy, ascending) {
          setState(() {
            _currentSortBy = sortBy;
            _isAscending = ascending;
          });
          _applyFiltersAndSort();
        },
      ),
    );
  }
}
