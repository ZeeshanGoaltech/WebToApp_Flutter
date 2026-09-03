import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_segment_pill.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_toggle.dart';
import 'package:web_to_app/modules/create_app/widgets/sheets/add_tab_sheet.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';

class Step2SettingsPage extends GetView<CreateAppController> {
  const Step2SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        0,
        Responsive.w(context, 24),
        Responsive.w(context, 24),
      ),
      child: Column(
        children: [
          CreateAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'bottom_navigation'.tr,
                      style: AppTextStyles.createSectionTitle(context),
                    ),
                    Obx(() => CreateToggle(
                          value: controller.bottomNavEnabled.value,
                          onChanged: controller.toggleBottomNav,
                        )),
                  ],
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() => Column(
                      children: [
                        ...controller.navTabs.map((tab) => _NavTabRow(tab: tab)),
                        SizedBox(height: Responsive.w(context, 8)),
                        _AddTabButton(onTap: () => _showAddTab(context)),
                      ],
                    )),
              ],
            ),
          ),
          SizedBox(height: Responsive.w(context, 16)),
          CreateAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'browser'.tr,
                  style: AppTextStyles.createSectionTitle(context),
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() => CreateToggleRow(
                      title: 'pull_to_refresh'.tr,
                      subtitle: 'pull_to_refresh_sub'.tr,
                      value: controller.pullToRefresh.value,
                      onChanged: (v) => controller.pullToRefresh.value = v,
                    )),
                _divider(context),
                Obx(() => CreateToggleRow(
                      title: 'desktop_mode'.tr,
                      subtitle: 'desktop_mode_sub'.tr,
                      value: controller.desktopMode.value,
                      onChanged: (v) => controller.desktopMode.value = v,
                    )),
                _divider(context),
                Obx(() => CreateToggleRow(
                      title: 'keep_screen_alive'.tr,
                      subtitle: 'keep_screen_alive_sub'.tr,
                      value: controller.keepScreenAlive.value,
                      onChanged: (v) => controller.keepScreenAlive.value = v,
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTab(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const AddTabSheet(),
    );
  }

  Widget _divider(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: Responsive.w(context, 16)),
      child: Container(
        height: 1,
        color: AppColors.createFieldBorder,
      ),
    );
  }
}

class _NavTabRow extends GetView<CreateAppController> {
  const _NavTabRow({required this.tab});

  final NavTabModel tab;

  String _iconAsset() {
    switch (tab.type) {
      case NavTabType.home:
        return CreateAppAssets.home;
      case NavTabType.privacyPolicy:
        return CreateAppAssets.shield;
      case NavTabType.whatsapp:
        return CreateAppAssets.whatsapp;
      case NavTabType.externalLink:
        return CreateAppAssets.externalLink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: Responsive.w(context, 8)),
      padding: EdgeInsets.all(Responsive.w(context, 13.16)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.createFieldBorder, width: 1.16),
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              FigmaSvgIcon(
                asset: CreateAppAssets.drag,
                size: Responsive.w(context, 15.989),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Container(
                width: Responsive.w(context, 31.996),
                height: Responsive.w(context, 31.996),
                decoration: BoxDecoration(
                  color: AppColors.createAccentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FigmaSvgIcon(
                    asset: _iconAsset(),
                    size: Responsive.w(context, 19.995),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                child: Text(
                  tab.label,
                  style: AppTextStyles.createFieldValue(context, size: 14),
                ),
              ),
              GestureDetector(
                onTap: () => controller.removeTab(tab.id),
                child: FigmaSvgIcon(
                  asset: CreateAppAssets.delete,
                  size: Responsive.w(context, 19.995),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.only(
              left: Responsive.w(context, 44),
              top: Responsive.w(context, 12),
            ),
            child: CreateSegmentPill(
              mode: tab.mode,
              onChanged: (m) => controller.setTabMode(tab.id, m),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTabButton extends StatelessWidget {
  const _AddTabButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: Responsive.w(context, 17.16)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(
              color: AppColors.createAccent,
              width: 1.16,
              style: BorderStyle.solid,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FigmaSvgIcon(
                asset: CreateAppAssets.add,
                size: Responsive.w(context, 19.995),
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Text('add_tab'.tr, style: AppTextStyles.createLink(context)),
            ],
          ),
        ),
      ),
    );
  }
}
