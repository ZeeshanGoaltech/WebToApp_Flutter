import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/interstitial_ad_trigger.dart';
import 'package:web_to_app/core/navigation/shell_back.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/home/widgets/dashboard_tab.dart';
import 'package:web_to_app/modules/home/widgets/guide_tab.dart';
import 'package:web_to_app/modules/home/widgets/home_bottom_nav.dart';
import 'package:web_to_app/modules/home/widgets/recent_section.dart';
import 'package:web_to_app/modules/home/widgets/settings_tab.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        await _handleBack(context);
      },
      child: _HomeFirstClickListener(
        child: Scaffold(
          backgroundColor: AppColors.homeBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Obx(
                    () => IndexedStack(
                      index: controller.selectedTab.value,
                      children: const [
                        DashboardTab(),
                        MyAppsTab(),
                        GuideTab(),
                        SettingsTab(),
                      ],
                    ),
                  ),
                ),
                Obx(
                  () => HomeBottomNav(
                    selectedIndex: controller.selectedTab.value,
                    onTabSelected: controller.selectTab,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleBack(BuildContext context) async {
    if (AdPresentationGate.shouldBlockBack) return;

    if (controller.selectedTab.value != 0) {
      controller.selectTab(0);
      return;
    }

    await ShellBack.handle(context);
  }
}

/// Captures taps on Home (except Pro) and shows 1st-click interstitial once/session.
class _HomeFirstClickListener extends StatefulWidget {
  const _HomeFirstClickListener({required this.child});

  final Widget child;

  @override
  State<_HomeFirstClickListener> createState() =>
      _HomeFirstClickListenerState();
}

class _HomeFirstClickListenerState extends State<_HomeFirstClickListener> {
  Offset? _downPosition;

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (event) {
        _downPosition = event.position;
      },
      onPointerUp: (event) {
        final down = _downPosition;
        _downPosition = null;
        if (down == null) return;
        // Ignore scrolls / drags — only treat short presses as clicks.
        if ((event.position - down).distance > 24) return;
        unawaited(InterstitialAdTrigger.showFirstClickInterstitialIfNeeded());
      },
      onPointerCancel: (_) {
        _downPosition = null;
      },
      child: widget.child,
    );
  }
}
