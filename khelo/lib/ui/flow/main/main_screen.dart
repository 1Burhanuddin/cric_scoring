import 'dart:io';

import 'package:cricheros_data/service/device/device_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cricheros/domain/extensions/context_extensions.dart';
import 'package:cricheros/gen/assets.gen.dart';
import 'package:cricheros/ui/app_route.dart';
import 'package:cricheros/ui/flow/app_links/app_links_handler.dart';
import 'package:cricheros/ui/flow/my_game/my_game_tab_screen.dart';
import 'package:cricheros/ui/flow/profile/profile_screen.dart';
import 'package:cricheros/ui/flow/stats/user_stat/user_stat_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cricheros_style/animations/on_tap_scale.dart';
import 'package:cricheros_style/extensions/context_extensions.dart';
import 'package:cricheros_style/navigation/bottom_navigation_bar.dart';
import 'package:cricheros_style/text/app_text_style.dart';

import '../../../domain/extensions/widget_extension.dart';
import '../home/home_screen.dart';
import '../notification/notification_permission_bottom_sheet.dart';
import 'main_screen_state_notifier.dart';
import 'notification_handler.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  final _materialPageController = PageController();
  final _cupertinoTabController = CupertinoTabController();
  int _selectedIndex = 0;
  late final NotificationHandler notificationHandler;
  late final AppLinksHandler _appLinksHandler;
  // Drives the ring pulsing outward around the start-match FAB — exact
  // match for the reference app's #tabbar .start .cir::after keyframe:
  // `animation: ping 1.9s ease infinite` (scale 1 -> 1.45, opacity .7 ->
  // 0), looping back-to-back with no gap between cycles.
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appLinksHandler = AppLinksHandler();
    notificationHandler = ref.read(notificationHandlerProvider);
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat();
    runPostFrame(() {
      notificationHandler.init(context);
      _appLinksHandler.init(context);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      // deallocate resources
      _materialPageController.dispose();
      _cupertinoTabController.dispose();
      _pulseController.dispose();
      WidgetsBinding.instance.removeObserver(this);
    }
  }

  @override
  void dispose() {
    _appLinksHandler.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _observerShowNotificationPermissionPrompt(context);
    final List<Widget> widgets = <Widget>[
      const HomeScreen(),
      const MyGameTabScreen(),
      const UserStatScreen(),
      ProfileScreen(changeTabToMyCricket: () {
        changeTab(1);
      }),
    ];

    if (Platform.isIOS) {
      return _cupertinoTabs(context, widgets);
    }
    return _materialTabs(context, widgets);
  }

  void _observerShowNotificationPermissionPrompt(BuildContext context) {
    ref.listen(
        mainScreenStateNotifierProvider
            .select((value) => value.showNotificationPermissionPrompt),
        (previous, next) async {
      if (next != null) {
        final isNotificationPermissionRequired =
            await DeviceService.isNotificationPermissionRequired();
        final bool hasPermission =
            await Permission.notification.status.isGranted;
        if (context.mounted &&
            isNotificationPermissionRequired &&
            !hasPermission) {
          ref
              .read(mainScreenStateNotifierProvider.notifier)
              .notificationPermissionPromptShown();
          await showPermissionBottomSheet(context);
        }
      }
    });
  }

  Widget _cupertinoTabs(BuildContext context, List<Widget> widgets) =>
      CupertinoTabScaffold(
        backgroundColor: context.colorScheme.surface,
        controller: _cupertinoTabController,
        tabBar: CupertinoTabBar(
          backgroundColor: context.colorScheme.surface,
          height: 65,
          border: Border(
            top: BorderSide(
              color: context.colorScheme.outline,
              width: 1,
            ),
          ),
          items: _tabItems(context)
              .map((e) => e.toBottomNavigationBarItem(context))
              .toList(),
        ),
        tabBuilder: (BuildContext context, int index) {
          return CupertinoTabView(
            builder: (BuildContext context) => widgets[index],
          );
        },
      );

  Widget _materialTabs(BuildContext context, List<Widget> widgets) => Scaffold(
        backgroundColor: context.colorScheme.surface,
        body: PageView(
          controller: _materialPageController,
          physics: const NeverScrollableScrollPhysics(),
          children: widgets,
        ),
        floatingActionButton: _startMatchButton(context),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _bottomBar(context),
      );

  // Exact match for the reference app's #tabbar .start button: 52px
  // circle, accent fill, drop shadow, press-scale, plus its ::after ring
  // — there that ring only shows while a workout is actively recording
  // (an app-state cricheros doesn't have a live-match check wired up for
  // yet); kept always-on here as a persistent "tap to start" pulse
  // instead of gating it behind data-layer work.
  Widget _startMatchButton(BuildContext context) {
    const size = 52.0;
    return Transform.translate(
      // Flutter's centerDocked math centers this widget's whole bounding
      // box (80px, sized to fit the pulse ring without clipping) on the
      // bar's top edge, which reads as sitting noticeably higher than the
      // reference's 52px circle raised by a fixed 24px — nudge down to
      // land in the same spot.
      offset: const Offset(0, 14),
      child: SizedBox(
        width: 80,
        height: 80,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final t = _pulseController.value;
                return Opacity(
                  opacity: (0.7 * (1 - t)).clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 1 + 0.45 * t,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: context.colorScheme.primary,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            OnTapScale(
              onTap: () => AppRoute.addMatch().push(context),
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: context.colorScheme.primary.withValues(alpha: 0.55),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: SvgPicture.string(
                    _cricketBallSvg,
                    width: 24,
                    height: 24,
                    colorFilter: ColorFilter.mode(
                      context.colorScheme.onPrimary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Just the ball, not a bat+ball combo — drawn in the reference icon
  // set's own convention (24x24, stroke-only, round caps/joins, ~1.7
  // stroke weight) rather than pulled from Flutter's built-in Material
  // icon set, which doesn't have a plain cricket ball at all.
  static const _cricketBallSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="12" cy="12" r="8.2" stroke="#000000" stroke-width="1.7"/>
  <path d="M4.8 8.6c4.8 3.2 9.6 3.2 14.4 0M4.8 15.4c4.8-3.2 9.6-3.2 14.4 0" stroke="#000000" stroke-width="1.5" stroke-linecap="round"/>
</svg>
''';

  // Docked FAB + notched bar, the same "raised center action" shape the
  // reference app uses for its own primary action (there: start workout,
  // here: start a new match) instead of that action living as just
  // another equal-weight tab.
  Widget _bottomBar(BuildContext context) {
    final tabs = _tabItems(context);
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: context.colorScheme.surface,
      elevation: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _bottomBarTab(context, tabs[0], 0),
          _bottomBarTab(context, tabs[1], 1),
          const SizedBox(width: 56), // clearance for the docked FAB
          _bottomBarTab(context, tabs[2], 2),
          _bottomBarTab(context, tabs[3], 3),
        ],
      ),
    );
  }

  Widget _bottomBarTab(BuildContext context, TabItem tab, int index) {
    final isActive = _selectedIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() => _selectedIndex = index);
          tab.onTap();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              isActive ? tab.tabActiveIcon : tab.tabIcon,
              const SizedBox(height: 3),
              Text(
                tab.tabLabel,
                style: AppTextStyle.caption.copyWith(
                  color: isActive
                      ? context.colorScheme.primary
                      : context.colorScheme.textDisabled,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<TabItem> _tabItems(BuildContext context) => [
        TabItem(
          tabIcon: _tabImage(context, imagePath: Assets.images.icHome),
          tabActiveIcon: _tabImage(context,
              imagePath: Assets.images.icHome, isActive: true),
          tabLabel: context.l10n.home_screen_title,
          route: '',
          onTap: () => _materialPageController.jumpToPage(0),
        ),
        TabItem(
          tabIcon: _tabImage(context, imagePath: Assets.images.icCricket),
          tabActiveIcon: _tabImage(
            context,
            imagePath: Assets.images.icCricket,
            isActive: true,
          ),
          tabLabel: context.l10n.my_cricket_screen_title,
          route: '',
          onTap: () => _materialPageController.jumpToPage(1),
        ),
        TabItem(
          tabIcon: _tabImage(context, imagePath: Assets.images.icStats),
          tabActiveIcon: _tabImage(context,
              imagePath: Assets.images.icStats, isActive: true),
          tabLabel: context.l10n.common_stats_title,
          route: '',
          onTap: () => _materialPageController.jumpToPage(2),
        ),
        TabItem(
          tabIcon: _tabImage(context, imagePath: Assets.images.icProfile),
          tabActiveIcon: _tabImage(context,
              imagePath: Assets.images.icProfile, isActive: true),
          tabLabel: context.l10n.tab_profile_title,
          route: '',
          onTap: () => _materialPageController.jumpToPage(3),
        ),
      ];

  // No pill/box behind the active icon — just a color change (muted gray
  // to accent red), matching the reference app's tab bar, where every tab
  // stays the same shape and only tint communicates selection.
  Widget _tabImage(
    BuildContext context, {
    required String imagePath,
    bool isActive = false,
  }) {
    return SvgPicture.asset(
      imagePath,
      height: 24,
      width: 24,
      colorFilter: ColorFilter.mode(
        isActive ? context.colorScheme.primary : context.colorScheme.textDisabled,
        BlendMode.srcIn,
      ),
    );
  }

  void changeTab(int tabNumber) {
    if (Platform.isIOS) {
      _cupertinoTabController.index = tabNumber;
    } else {
      _materialPageController.jumpToPage(tabNumber);
      setState(() => _selectedIndex = tabNumber);
    }
  }
}
