import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
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
    if (controller.selectedTab.value != 0) {
      controller.selectTab(0);
      return;
    }

    if (controller.isExitSheetVisible.value) return;

    controller.isExitSheetVisible.value = true;
    final shouldExit = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _HomeExitSheet(),
    );
    controller.isExitSheetVisible.value = false;

    if (shouldExit == true) {
      await SystemNavigator.pop();
    }
  }
}

class _HomeExitSheet extends StatelessWidget {
  const _HomeExitSheet();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 16),
        0,
        Responsive.w(context, 16),
        bottomInset + Responsive.w(context, 16),
      ),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.w(context, 28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.16),
              blurRadius: Responsive.w(context, 32),
              offset: Offset(0, Responsive.w(context, 12)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.w(context, 56),
              height: Responsive.w(context, 56),
              decoration: BoxDecoration(
                color: AppColors.homeAccentLight,
                borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
              ),
              child: Icon(
                Icons.logout_rounded,
                size: Responsive.w(context, 28),
                color: AppColors.homeAccent,
              ),
            ),
            SizedBox(height: Responsive.w(context, 16)),
            Text(
              'home_exit_title'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.settingsHeaderTitle(context),
            ),
            SizedBox(height: Responsive.w(context, 8)),
            Text(
              'home_exit_message'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.createRowSubtitle(
                context,
              ).copyWith(height: 1.45),
            ),
            SizedBox(height: Responsive.w(context, 22)),
            Row(
              children: [
                Expanded(
                  child: _ExitSheetButton(
                    label: 'home_exit_cancel'.tr,
                    background: AppColors.createFieldBg,
                    foreground: AppColors.createMuted,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: _ExitSheetButton(
                    label: 'home_exit_confirm'.tr,
                    background: AppColors.primary,
                    foreground: Colors.white,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExitSheetButton extends StatelessWidget {
  const _ExitSheetButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.w(context, 14)),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.createFieldValue(
              context,
              size: 14,
            ).copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
