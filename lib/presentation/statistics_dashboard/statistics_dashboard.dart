import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievement_badges_widget.dart';
import './widgets/ai_insights_widget.dart';
import './widgets/category_breakdown_widget.dart';
import './widgets/completion_rate_widget.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/export_options_widget.dart';
import './widgets/metric_card_widget.dart';
import './widgets/productivity_trends_widget.dart';
import './widgets/time_analysis_widget.dart';

class StatisticsDashboard extends StatefulWidget {
  const StatisticsDashboard({super.key});

  @override
  State<StatisticsDashboard> createState() => _StatisticsDashboardState();
}

class _StatisticsDashboardState extends State<StatisticsDashboard>
    with TickerProviderStateMixin {
  String _selectedDateRange = 'Semaine';
  late ScrollController _scrollController;
  bool _showFloatingButton = false;

  // Mock data for statistics
  final List<Map<String, dynamic>> _trendsData = [
    {"day": "Lundi", "productivity": 85.0},
    {"day": "Mardi", "productivity": 92.0},
    {"day": "Mercredi", "productivity": 78.0},
    {"day": "Jeudi", "productivity": 88.0},
    {"day": "Vendredi", "productivity": 95.0},
    {"day": "Samedi", "productivity": 70.0},
    {"day": "Dimanche", "productivity": 65.0},
  ];

  final List<Map<String, dynamic>> _categoryData = [
    {"name": "Travail", "count": 45, "percentage": 35.0},
    {"name": "Personnel", "count": 32, "percentage": 25.0},
    {"name": "Projets", "count": 28, "percentage": 22.0},
    {"name": "Urgences", "count": 15, "percentage": 12.0},
    {"name": "Autres", "count": 8, "percentage": 6.0},
  ];

  final List<Map<String, dynamic>> _timeData = [
    {"period": "Matin", "hours": 6.5},
    {"period": "Après-midi", "hours": 8.2},
    {"period": "Soir", "hours": 4.8},
    {"period": "Nuit", "hours": 1.2},
  ];

  final List<Map<String, dynamic>> _insightsData = [
    {
      "type": "productivity",
      "title": "Pic de productivité",
      "description":
          "Votre productivité est maximale le vendredi après-midi. Planifiez vos tâches importantes à ce moment.",
      "action": "Voir les recommandations"
    },
    {
      "type": "pattern",
      "title": "Modèle détecté",
      "description":
          "Vous complétez 23% plus de tâches quand vous les planifiez la veille.",
      "action": "Activer la planification automatique"
    },
    {
      "type": "suggestion",
      "title": "Suggestion d'optimisation",
      "description":
          "Regrouper les tâches similaires pourrait vous faire gagner 45 minutes par jour.",
      "action": "Appliquer la suggestion"
    },
    {
      "type": "warning",
      "title": "Attention aux surcharges",
      "description":
          "Vous avez tendance à programmer trop de tâches le lundi. Répartissez mieux votre charge.",
      "action": "Ajuster la planification"
    },
  ];

  final List<Map<String, dynamic>> _achievementsData = [
    {
      "name": "Productif",
      "description": "Complétez 100 tâches",
      "icon": "star",
      "unlocked": true,
      "progress": 128,
      "target": 100,
    },
    {
      "name": "Régulier",
      "description": "7 jours consécutifs d'activité",
      "icon": "calendar_today",
      "unlocked": true,
      "progress": 7,
      "target": 7,
    },
    {
      "name": "Organisé",
      "description": "Utilisez 5 catégories différentes",
      "icon": "folder",
      "unlocked": true,
      "progress": 5,
      "target": 5,
    },
    {
      "name": "Rapide",
      "description": "Complétez 20 tâches en une journée",
      "icon": "flash_on",
      "unlocked": false,
      "progress": 15,
      "target": 20,
    },
    {
      "name": "Collaborateur",
      "description": "Partagez 10 tâches avec l'équipe",
      "icon": "group",
      "unlocked": false,
      "progress": 6,
      "target": 10,
    },
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.offset > 200 && !_showFloatingButton) {
      setState(() {
        _showFloatingButton = true;
      });
    } else if (_scrollController.offset <= 200 && _showFloatingButton) {
      setState(() {
        _showFloatingButton = false;
      });
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Statistiques',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            onPressed: () => _showFilterOptions(context),
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
          IconButton(
            onPressed: () => _refreshData(),
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: colorScheme.onSurface,
              size: 6.w,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Range Selector
              DateRangeSelectorWidget(
                selectedRange: _selectedDateRange,
                onRangeChanged: (range) {
                  setState(() {
                    _selectedDateRange = range;
                  });
                  _updateDataForRange(range);
                },
              ),

              // Key Metrics Row
              SizedBox(
                height: 18.h,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 2.w),
                  children: [
                    SizedBox(
                      width: 40.w,
                      child: MetricCardWidget(
                        title: 'Tâches Complétées',
                        value: '128',
                        subtitle: '+12% cette semaine',
                        icon: Icons.check_circle,
                        iconColor: colorScheme.primary,
                        onTap: () => Navigator.pushNamed(context, '/task-list'),
                      ),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: MetricCardWidget(
                        title: 'Temps Moyen',
                        value: '2.4h',
                        subtitle: 'par tâche',
                        icon: Icons.schedule,
                        iconColor: colorScheme.secondary,
                        onTap: () =>
                            Navigator.pushNamed(context, '/calendar-view'),
                      ),
                    ),
                    SizedBox(
                      width: 40.w,
                      child: MetricCardWidget(
                        title: 'Productivité',
                        value: '87%',
                        subtitle: 'score global',
                        icon: Icons.trending_up,
                        iconColor: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ),

              // Completion Rate
              CompletionRateWidget(
                completionRate: 87.0,
                completedTasks: 128,
                totalTasks: 147,
              ),

              // Productivity Trends
              ProductivityTrendsWidget(
                trendsData: _trendsData,
              ),

              // Category Breakdown
              CategoryBreakdownWidget(
                categoryData: _categoryData,
              ),

              // Time Analysis
              TimeAnalysisWidget(
                timeData: _timeData,
              ),

              // Achievement Badges
              AchievementBadgesWidget(
                achievements: _achievementsData,
              ),

              // AI Insights
              AiInsightsWidget(
                insights: _insightsData,
              ),

              // Export Options
              ExportOptionsWidget(
                statisticsData: _getStatisticsData(),
              ),

              // Bottom spacing
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
      floatingActionButton: _showFloatingButton
          ? FloatingActionButton(
              onPressed: _scrollToTop,
              backgroundColor: colorScheme.primary,
              child: CustomIconWidget(
                iconName: 'keyboard_arrow_up',
                color: Colors.white,
                size: 6.w,
              ),
            )
          : null,
      bottomNavigationBar: Container(
        height: 8.h,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomNavItem(
              context,
              'Dashboard',
              Icons.dashboard_outlined,
              '/dashboard',
              false,
            ),
            _buildBottomNavItem(
              context,
              'Tâches',
              Icons.list_alt_outlined,
              '/task-list',
              false,
            ),
            _buildBottomNavItem(
              context,
              'Calendrier',
              Icons.calendar_today_outlined,
              '/calendar-view',
              false,
            ),
            _buildBottomNavItem(
              context,
              'Stats',
              Icons.analytics,
              '/statistics-dashboard',
              true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavItem(
    BuildContext context,
    String label,
    IconData icon,
    String route,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: () {
        if (!isSelected) {
          Navigator.pushNamed(context, route);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h, horizontal: 3.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: icon.codePoint.toString(),
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 6.w,
            ),
            SizedBox(height: 0.5.h),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Données mises à jour'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateDataForRange(String range) {
    // Update data based on selected range
    // This would typically fetch new data from an API
    setState(() {
      // Update mock data based on range
    });
  }

  void _showFilterOptions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(4.w)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Options de Filtrage',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              _buildFilterOption(context, 'Toutes les catégories', true),
              _buildFilterOption(context, 'Travail uniquement', false),
              _buildFilterOption(context, 'Personnel uniquement', false),
              _buildFilterOption(context, 'Projets uniquement', false),
              SizedBox(height: 2.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Appliquer'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(
      BuildContext context, String title, bool isSelected) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      title: Text(title),
      trailing: isSelected
          ? CustomIconWidget(
              iconName: 'check',
              color: colorScheme.primary,
              size: 5.w,
            )
          : null,
      onTap: () {
        // Handle filter selection
      },
    );
  }

  Map<String, dynamic> _getStatisticsData() {
    return {
      'completionRate': 87.0,
      'completedTasks': 128,
      'totalTasks': 147,
      'productivityTrend': 'En hausse',
      'bestPeriod': 'Vendredi après-midi',
      'avgTimePerTask': 2.4,
      'categories': _categoryData,
      'insights': _insightsData,
      'trends': _trendsData,
      'timeAnalysis': _timeData,
      'achievements': _achievementsData,
    };
  }
}
