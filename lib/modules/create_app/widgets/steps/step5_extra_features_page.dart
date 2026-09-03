import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_toggle.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';

class Step5ExtraFeaturesPage extends GetView<CreateAppController> {
  const Step5ExtraFeaturesPage({super.key});

  List<_FeatureItem> _items() => [
        _FeatureItem(
          key: 'noInternetDialog',
          icon: CreateAppAssets.wifiOff,
          title: 'feat_no_internet'.tr,
          subtitle: 'feat_no_internet_sub'.tr,
        ),
        _FeatureItem(
          key: 'pushNotificationPopup',
          icon: CreateAppAssets.notificationPopup,
          title: 'feat_push_popup'.tr,
          subtitle: 'feat_push_popup_sub'.tr,
        ),
        _FeatureItem(
          key: 'loadingScreen',
          icon: CreateAppAssets.hourglass,
          title: 'feat_loading'.tr,
          subtitle: 'feat_loading_sub'.tr,
        ),
        _FeatureItem(
          key: 'errorScreen',
          icon: CreateAppAssets.errorScreen,
          title: 'feat_error'.tr,
          subtitle: 'feat_error_sub'.tr,
        ),
        _FeatureItem(
          key: 'exitConfirmation',
          icon: CreateAppAssets.exitConfirm,
          title: 'feat_exit'.tr,
          subtitle: 'feat_exit_sub'.tr,
        ),
        _FeatureItem(
          key: 'backButtonHandling',
          icon: CreateAppAssets.backHandling,
          title: 'feat_back'.tr,
          subtitle: 'feat_back_sub'.tr,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final items = _items();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        0,
        Responsive.w(context, 24),
        Responsive.w(context, 24),
      ),
      child: CreateAppCard(
        padding: EdgeInsets.zero,
        child: Obx(
          () => Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Padding(
                    padding: EdgeInsets.only(left: Responsive.w(context, 72)),
                    child: Container(
                      height: 1,
                      color: AppColors.createFieldBorder,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(Responsive.w(context, 16)),
                  child: Row(
                    children: [
                      Container(
                        width: Responsive.w(context, 39.99),
                        height: Responsive.w(context, 39.99),
                        decoration: const BoxDecoration(
                          color: AppColors.createAccentLight,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: FigmaSvgIcon(
                            asset: items[i].icon,
                            size: Responsive.w(context, 19.995),
                          ),
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 16)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              items[i].title,
                              style: AppTextStyles.createRowTitle(context),
                            ),
                            Text(
                              items[i].subtitle,
                              style: AppTextStyles.createRowSubtitle(context),
                            ),
                          ],
                        ),
                      ),
                      CreateToggle(
                        value:
                            controller.extraFeatures[items[i].key] ?? false,
                        onChanged: (v) =>
                            controller.toggleExtraFeature(items[i].key, v),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureItem {
  const _FeatureItem({
    required this.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String key;
  final String icon;
  final String title;
  final String subtitle;
}
