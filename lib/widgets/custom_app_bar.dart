import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Custom app bar implementing Contextual App Bars pattern
/// Adapts title and actions based on scroll position and current task selection state
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double? elevation;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool automaticallyImplyLeading;
  final PreferredSizeWidget? bottom;
  final double? titleSpacing;
  final double? leadingWidth;
  final TextStyle? titleTextStyle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.elevation,
    this.backgroundColor,
    this.foregroundColor,
    this.automaticallyImplyLeading = true,
    this.bottom,
    this.titleSpacing,
    this.leadingWidth,
    this.titleTextStyle,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      title: Text(
        title,
        style: titleTextStyle ??
            GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? colorScheme.onSurface,
              letterSpacing: -0.02,
            ),
      ),
      actions: _buildActions(context),
      leading: _buildLeading(context),
      centerTitle: centerTitle,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      automaticallyImplyLeading: automaticallyImplyLeading,
      bottom: bottom,
      titleSpacing: titleSpacing,
      leadingWidth: leadingWidth,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: action,
        );
      }
      return action;
    }).toList();
  }

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0.0),
      );
}

/// Sliver app bar variant for scroll-based adaptations
class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double expandedHeight;
  final Widget? flexibleSpace;
  final bool pinned;
  final bool floating;
  final bool snap;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? titleTextStyle;
  final bool showBackButton;
  final VoidCallback? onBackPressed;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.expandedHeight = 120.0,
    this.flexibleSpace,
    this.pinned = true,
    this.floating = false,
    this.snap = false,
    this.backgroundColor,
    this.foregroundColor,
    this.titleTextStyle,
    this.showBackButton = false,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SliverAppBar(
      title: Text(
        title,
        style: titleTextStyle ??
            GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: foregroundColor ?? colorScheme.onSurface,
              letterSpacing: -0.02,
            ),
      ),
      actions: _buildActions(context),
      leading: _buildLeading(context),
      centerTitle: centerTitle,
      expandedHeight: expandedHeight,
      flexibleSpace: flexibleSpace ??
          FlexibleSpaceBar(
            title: Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            ),
            centerTitle: centerTitle,
            titlePadding:
                const EdgeInsets.only(left: 16, bottom: 16, right: 16),
          ),
      pinned: pinned,
      floating: floating,
      snap: snap,
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      surfaceTintColor: Colors.transparent,
      shadowColor: colorScheme.shadow,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton || Navigator.of(context).canPop()) {
      return IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
        tooltip: 'Back',
      );
    }

    return null;
  }

  List<Widget>? _buildActions(BuildContext context) {
    if (actions == null) return null;

    return actions!.map((action) {
      if (action is IconButton) {
        return Padding(
          padding: const EdgeInsets.only(right: 4),
          child: action,
        );
      }
      return action;
    }).toList();
  }
}
