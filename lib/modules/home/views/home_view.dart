import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
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
