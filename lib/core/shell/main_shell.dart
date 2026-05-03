import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../router/app_router.dart';
import '../../shared/widgets/offline_banner.dart';

/// Persistent bottom navigation shell – mirrors the web's MobileTabBar.
class MainShell extends ConsumerWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded, label: 'Home', path: '/home'),
    _TabItem(icon: Icons.article_rounded, label: 'Visas', path: '/visas'),
    _TabItem(icon: Icons.info_outline_rounded, label: 'About', path: '/about'),
    _TabItem(icon: Icons.mail_outline_rounded, label: 'Contact', path: '/contact'),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isAr = locale.languageCode == 'ar';
    final currentIndex = _currentIndex(context);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppConstants.colorBackground,
        body: Stack(
          children: [
            child,
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: OfflineBanner(),
            ),
          ],
        ),
        bottomNavigationBar: RepaintBoundary(
          child: _BottomNavBar(
            currentIndex: currentIndex,
            isAr: isAr,
            onTap: (i) {
              // ── Haptic: distinct selection click on every tab switch ──────────
              // selectionClick is lightweight — feels like a hardware switch.
              HapticFeedback.selectionClick();
              context.go(_tabs[i].path);
            },
          ),
        ),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final bool isAr;
  final ValueChanged<int> onTap;

  const _BottomNavBar({
    required this.currentIndex,
    required this.isAr,
    required this.onTap,
  });

  static const _labelsAr = ['الرئيسية', 'التأشيرات', 'عن الصندوق', 'التواصل'];
  static const _labelsEn = ['Home', 'Visas', 'About', 'Contact'];

  @override
  Widget build(BuildContext context) {
    final labels = isAr ? _labelsAr : _labelsEn;
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: AppConstants.colorCard,
        border: Border(
          top: BorderSide(color: AppConstants.colorBorder, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth = constraints.maxWidth / MainShell._tabs.length;
            const pillWidth = 32.0;
            return Stack(
              children: [
                // ── Sliding indicator pill ──────────────────────────────
                // Slides smoothly between tab positions with easeOutCubic.
                // Lives at the very top of the nav bar, above the border.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: (tabWidth * currentIndex) +
                      (tabWidth - pillWidth) / 2,
                  child: Container(
                    width: pillWidth,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppConstants.colorPrimary,
                      borderRadius: BorderRadius.circular(
                          AppConstants.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.colorPrimary
                              .withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                // ── Tab items ───────────────────────────────────────────
                SizedBox(
                  height: 60 + bottom,
                  child: Row(
            children: List.generate(MainShell._tabs.length, (i) {
              final tab = MainShell._tabs[i];
              final selected = i == currentIndex;
              return Expanded(
                child: _NavItem(
                  tab: tab,
                  label: labels[i],
                  selected: selected,
                  bottomPadding: bottom,
                  onTap: () => onTap(i),
                ),
              );
            }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Individual nav item with animated press scale for tactile feedback.
class _NavItem extends StatefulWidget {
  final _TabItem tab;
  final String label;
  final bool selected;
  final double bottomPadding;
  final VoidCallback onTap;

  const _NavItem({
    required this.tab,
    required this.label,
    required this.selected,
    required this.bottomPadding,
    required this.onTap,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
      reverseDuration: const Duration(milliseconds: 180),
    );
    _scale = Tween<double>(begin: 1.0, end: 0.82).animate(
      CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: AppConstants.durationFast,
          padding: EdgeInsets.only(bottom: widget.bottomPadding, top: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppConstants.durationFast,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: widget.selected
                    ? BoxDecoration(
                        color: AppConstants.colorPrimary
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(
                            AppConstants.radiusFull),
                      )
                    : null,
                child: AnimatedSwitcher(
                  duration: AppConstants.durationFast,
                  child: Icon(
                    widget.tab.icon,
                    key: ValueKey(widget.selected),
                    size: 22,
                    color: widget.selected
                        ? AppConstants.colorPrimary
                        : AppConstants.colorBodyText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppConstants.durationFast,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: widget.selected
                      ? AppConstants.colorPrimary
                      : AppConstants.colorBodyText,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final String label;
  final String path;
  const _TabItem({
    required this.icon,
    required this.label,
    required this.path,
  });
}
