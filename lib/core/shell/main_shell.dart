import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_constants.dart';
import '../providers/app_providers.dart';
import '../router/app_router.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/visas/screens/visas_screen.dart';
import '../../features/about/screens/about_screen.dart';
import '../../features/contact/screens/contact_screen.dart';
import '../../shared/widgets/offline_banner.dart';

/// Persistent bottom navigation shell with IndexedStack tab keepAlive.
///
/// ## Performance Architecture
/// All four tab screens are kept alive in an [IndexedStack] at all times.
/// Switching tabs is therefore 0ms — no unmount, no network re-fetch,
/// no animation delay. This is the same model used by Telegram, Instagram,
/// and WhatsApp.
///
/// ## State Restoration
/// On every build, the current GoRouter location is written to
/// [AppPersistenceService]. When the app is force-killed and reopened,
/// [appRouterProvider] reads this value as [GoRouter.initialLocation],
/// rendering the exact same screen instantly.
///
/// ## Sub-route Overlay
/// When the user navigates to a sub-route (e.g. `/visas/some-slug`),
/// the [IndexedStack] is made [Offstage] (invisible but kept alive in memory)
/// and the [child] from GoRouter's ShellRoute is rendered on top.
/// When the user pops back to a tab, the IndexedStack reappears instantly
/// — the VisasScreen still has its category filter selected and scroll position.
class MainShell extends ConsumerWidget {
  /// The current ShellRoute child — used for sub-routes (e.g. VisaDetailScreen).
  /// Null-safe: ignored when on a top-level tab path.
  final Widget child;
  const MainShell({super.key, required this.child});

  static const _tabs = [
    _TabItem(icon: Icons.home_rounded,        label: 'Home',    path: '/home'),
    _TabItem(icon: Icons.article_rounded,     label: 'Visas',   path: '/visas'),
    _TabItem(icon: Icons.info_outline_rounded, label: 'About',  path: '/about'),
    _TabItem(icon: Icons.mail_outline_rounded, label: 'Contact',path: '/contact'),
  ];

  static const _tabScreens = [
    HomeScreen(),
    VisasScreen(),
    AboutScreen(),
    ContactScreen(),
  ];

  int _tabIndex(String location) {
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  bool _isExactTab(String location) =>
      _tabs.any((t) => t.path == location);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale      = ref.watch(localeNotifierProvider);
    final isAr        = locale.languageCode == 'ar';
    final location    = GoRouterState.of(context).matchedLocation;
    final currentIndex = _tabIndex(location);
    final onTab       = _isExactTab(location);

    // ── Route persistence ──────────────────────────────────────────────────
    // Written on every build = written on every navigation event.
    // Fire-and-forget: SharedPreferences.setString is async internally
    // but we don't await it — zero impact on frame rendering.
    ref.read(appPersistenceProvider).saveRoute(location);

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: AppConstants.colorBackground,
        body: Stack(
          children: [
            // ── Always-alive tab stack ───────────────────────────────────
            // Offstage = invisible + no hit-testing, but STAYS IN THE TREE.
            // All 4 screens remain mounted, preserving scroll positions,
            // Riverpod state, and loaded data across tab switches.
            Offstage(
              offstage: !onTab,
              child: IndexedStack(
                index: currentIndex,
                children: _tabScreens,
              ),
            ),

            // ── Sub-route overlay (e.g. VisaDetailScreen) ───────────────
            // When the user drills into a detail page, it renders here,
            // on top of the (now offstage) IndexedStack.
            if (!onTab) child,

            // ── Offline banner (always on top) ───────────────────────────
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
              HapticFeedback.selectionClick();
              context.go(_tabs[i].path);
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom nav bar (unchanged visuals, same premium feel)
// ─────────────────────────────────────────────────────────────────────────────

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
        border: Border(top: BorderSide(color: AppConstants.colorBorder, width: 1)),
      ),
      child: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tabWidth  = constraints.maxWidth / MainShell._tabs.length;
            const pillWidth = 32.0;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  top: 0,
                  left: (tabWidth * currentIndex) + (tabWidth - pillWidth) / 2,
                  child: Container(
                    width: pillWidth,
                    height: 3,
                    decoration: BoxDecoration(
                      color: AppConstants.colorPrimary,
                      borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      boxShadow: [
                        BoxShadow(
                          color: AppConstants.colorPrimary.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 60 + bottom,
                  child: Row(
                    children: List.generate(MainShell._tabs.length, (i) {
                      return Expanded(
                        child: _NavItem(
                          tab: MainShell._tabs[i],
                          label: labels[i],
                          selected: i == currentIndex,
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

class _NavItemState extends State<_NavItem> with SingleTickerProviderStateMixin {
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
      onTapUp: (_) { _pressCtrl.reverse(); widget.onTap(); },
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: widget.selected
                    ? BoxDecoration(
                        color: AppConstants.colorPrimary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppConstants.radiusFull),
                      )
                    : null,
                child: AnimatedSwitcher(
                  duration: AppConstants.durationFast,
                  child: Icon(
                    widget.tab.icon,
                    key: ValueKey(widget.selected),
                    size: 22,
                    color: widget.selected ? AppConstants.colorPrimary : AppConstants.colorBodyText,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: AppConstants.durationFast,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.w400,
                  color: widget.selected ? AppConstants.colorPrimary : AppConstants.colorBodyText,
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
  const _TabItem({required this.icon, required this.label, required this.path});
}
