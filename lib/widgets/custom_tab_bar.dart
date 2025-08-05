import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tab item data structure
class CustomTabItem {
  final String label;
  final IconData? icon;
  final Widget? customIcon;
  final String? route;
  final int? badgeCount;

  const CustomTabItem({
    required this.label,
    this.icon,
    this.customIcon,
    this.route,
    this.badgeCount,
  });
}

/// Custom tab bar implementing contextual navigation patterns
/// Optimized for mobile productivity workflows with gesture support
class CustomTabBar extends StatefulWidget {
  final List<CustomTabItem> tabs;
  final int initialIndex;
  final ValueChanged<int>? onTap;
  final bool isScrollable;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? indicatorColor;
  final double? indicatorWeight;
  final EdgeInsetsGeometry? padding;
  final TabAlignment? tabAlignment;
  final bool showIcons;
  final bool showBadges;

  const CustomTabBar({
    super.key,
    required this.tabs,
    this.initialIndex = 0,
    this.onTap,
    this.isScrollable = false,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.indicatorColor,
    this.indicatorWeight,
    this.padding,
    this.tabAlignment,
    this.showIcons = true,
    this.showBadges = true,
  });

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: widget.tabs.length,
      initialIndex: widget.initialIndex,
      vsync: this,
    );
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      final index = _tabController.index;
      widget.onTap?.call(index);

      // Navigate to route if specified
      final tab = widget.tabs[index];
      if (tab.route != null) {
        Navigator.pushNamed(context, tab.route!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tabBarTheme = theme.tabBarTheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          child: TabBar(
            controller: _tabController,
            tabs: _buildTabs(),
            isScrollable: widget.isScrollable,
            tabAlignment: widget.tabAlignment ??
                (widget.isScrollable ? TabAlignment.start : TabAlignment.fill),
            labelColor: widget.selectedColor ??
                tabBarTheme.labelColor ??
                colorScheme.primary,
            unselectedLabelColor: widget.unselectedColor ??
                tabBarTheme.unselectedLabelColor ??
                colorScheme.onSurface.withAlpha(153),
            indicatorColor: widget.indicatorColor ??
                tabBarTheme.indicatorColor ??
                colorScheme.primary,
            indicatorWeight: widget.indicatorWeight ?? 3.0,
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.1,
            ),
            unselectedLabelStyle: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.1,
            ),
            splashFactory: InkRipple.splashFactory,
            overlayColor: WidgetStateProperty.all(
              colorScheme.primary.withAlpha(26),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTabs() {
    return widget.tabs.map((tab) => _buildTab(tab)).toList();
  }

  Widget _buildTab(CustomTabItem tab) {
    final hasIcon =
        widget.showIcons && (tab.icon != null || tab.customIcon != null);
    final hasBadge =
        widget.showBadges && tab.badgeCount != null && tab.badgeCount! > 0;

    Widget tabContent = Text(tab.label);

    if (hasIcon) {
      Widget iconWidget = tab.customIcon ?? Icon(tab.icon, size: 20);

      if (hasBadge) {
        iconWidget = Badge(
          label: Text(
            tab.badgeCount! > 99 ? '99+' : tab.badgeCount.toString(),
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          child: iconWidget,
        );
      }

      tabContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(tab.label),
        ],
      );
    } else if (hasBadge) {
      tabContent = Badge(
        label: Text(
          tab.badgeCount! > 99 ? '99+' : tab.badgeCount.toString(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        child: Text(tab.label),
      );
    }

    return Tab(child: tabContent);
  }
}

/// Segmented tab bar for binary or ternary choices
class CustomSegmentedTabBar extends StatefulWidget {
  final List<CustomTabItem> tabs;
  final int selectedIndex;
  final ValueChanged<int>? onSelectionChanged;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final EdgeInsetsGeometry? padding;
  final double? height;

  const CustomSegmentedTabBar({
    super.key,
    required this.tabs,
    this.selectedIndex = 0,
    this.onSelectionChanged,
    this.backgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.padding,
    this.height,
  });

  @override
  State<CustomSegmentedTabBar> createState() => _CustomSegmentedTabBarState();
}

class _CustomSegmentedTabBarState extends State<CustomSegmentedTabBar> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(CustomSegmentedTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != oldWidget.selectedIndex) {
      _selectedIndex = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: widget.height ?? 48,
      padding: widget.padding ?? const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withAlpha(51),
          width: 1,
        ),
      ),
      child: Row(
        children: widget.tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final isSelected = index == _selectedIndex;

          return Expanded(
            child: GestureDetector(
              onTap: () => _handleTap(index, tab.route),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (widget.selectedColor ?? colorScheme.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (tab.icon != null) ...[
                        Icon(
                          tab.icon,
                          size: 18,
                          color: isSelected
                              ? Colors.white
                              : (widget.unselectedColor ??
                                  colorScheme.onSurface.withAlpha(179)),
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        tab.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (widget.unselectedColor ??
                                  colorScheme.onSurface.withAlpha(179)),
                          letterSpacing: 0.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _handleTap(int index, String? route) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      widget.onSelectionChanged?.call(index);

      if (route != null) {
        Navigator.pushNamed(context, route);
      }
    }
  }
}

/// Productivity-focused tab bar with predefined task management tabs
class ProductivityTabBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onTap;
  final bool showBadges;

  const ProductivityTabBar({
    super.key,
    this.selectedIndex = 0,
    this.onTap,
    this.showBadges = true,
  });

  // Predefined tabs for productivity workflows
  static const List<CustomTabItem> _productivityTabs = [
    CustomTabItem(
      label: 'Today',
      icon: Icons.today_outlined,
      route: '/task-list',
    ),
    CustomTabItem(
      label: 'Upcoming',
      icon: Icons.schedule_outlined,
      route: '/calendar-view',
    ),
    CustomTabItem(
      label: 'Completed',
      icon: Icons.check_circle_outline,
      route: '/statistics-dashboard',
    ),
    CustomTabItem(
      label: 'All Tasks',
      icon: Icons.list_alt_outlined,
      route: '/task-list',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return CustomTabBar(
      tabs: _productivityTabs,
      initialIndex: selectedIndex,
      onTap: onTap,
      isScrollable: true,
      showBadges: showBadges,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}
