import 'package:flutter/material.dart';
import '../presentation/task_detail/task_detail.dart';
import '../presentation/task_creation/task_creation.dart';
import '../presentation/task_list/task_list.dart';
import '../presentation/dashboard/dashboard.dart';
import '../presentation/calendar_view/calendar_view.dart';
import '../presentation/statistics_dashboard/statistics_dashboard.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String taskDetail = '/task-detail';
  static const String taskCreation = '/task-creation';
  static const String taskList = '/task-list';
  static const String dashboard = '/dashboard';
  static const String calendarView = '/calendar-view';
  static const String statisticsDashboard = '/statistics-dashboard';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const TaskDetail(),
    taskDetail: (context) => const TaskDetail(),
    taskCreation: (context) => const TaskCreation(),
    taskList: (context) => const TaskList(),
    dashboard: (context) => const Dashboard(),
    calendarView: (context) => const CalendarView(),
    statisticsDashboard: (context) => const StatisticsDashboard(),
    // TODO: Add your other routes here
  };
}
