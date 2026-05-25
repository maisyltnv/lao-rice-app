import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// Responsive sizing for checkout screens across phone sizes and tablets.
abstract final class CheckoutLayout {
  static const double maxContentWidth = 560;
  static const double _compactHeight = 700;
  static const double _tabletWidth = 600;

  static bool isCompactHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height < _compactHeight;

  static bool isTabletWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletWidth;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = w >= _tabletWidth ? AppSpacing.xxl : AppSpacing.lg;
    final vertical = isCompactHeight(context) ? AppSpacing.md : AppSpacing.lg;
    return EdgeInsets.fromLTRB(horizontal, vertical, horizontal, AppSpacing.md);
  }

  static double titleFontSize(BuildContext context) =>
      isCompactHeight(context) ? 18 : 22;

  static double sectionGap(BuildContext context) =>
      isCompactHeight(context) ? AppSpacing.md : AppSpacing.lg;

  static double fieldGap(BuildContext context) =>
      isCompactHeight(context) ? AppSpacing.md : AppSpacing.lg;

  static int addressMaxLines(BuildContext context) =>
      isCompactHeight(context) ? 2 : 3;

  /// Scrollable checkout body — must not use [Center] (breaks inside [ListView]).
  static Widget scrollBody(
    BuildContext context, {
    required List<Widget> children,
    ScrollController? controller,
  }) {
    final padding = pagePadding(context);
    return SingleChildScrollView(
      controller: controller,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: padding,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: maxContentWidth),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ),
      ),
    );
  }
}
