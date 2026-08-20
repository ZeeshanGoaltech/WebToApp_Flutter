import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/small_native_ad_widget.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_toggle.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';

class Step4PermissionsPage extends GetView<CreateAppController> {
  const Step4PermissionsPage({super.key});

  static List<_PermissionItem> _items() => [
    _PermissionItem(
      key: 'push',
      icon: CreateAppAssets.bell,
      title: 'perm_push'.tr,
      subtitle: 'perm_push_sub'.tr,
    ),
    _PermissionItem(
      key: 'camera',
      icon: CreateAppAssets.camera,
      title: 'perm_camera'.tr,
      subtitle: 'perm_camera_sub'.tr,
    ),
    _PermissionItem(
      key: 'location',
      icon: CreateAppAssets.location,
      title: 'perm_location'.tr,
      subtitle: 'perm_location_sub'.tr,
    ),
    _PermissionItem(
      key: 'storage',
      icon: CreateAppAssets.storage,
      title: 'perm_storage'.tr,
      subtitle: 'perm_storage_sub'.tr,
    ),
    _PermissionItem(
      key: 'microphone',
      icon: CreateAppAssets.mic,
      title: 'perm_microphone'.tr,
      subtitle: 'perm_microphone_sub'.tr,
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
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(Responsive.w(context, 14)),
            decoration: BoxDecoration(
              color: AppColors.createInfoBanner,
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FigmaSvgIcon(
                  asset: CreateAppAssets.info,
                  size: Responsive.w(context, 19.995),
                ),
                SizedBox(height: Responsive.w(context, 10)),
                Text(
                  'perm_select_hint'.tr,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.createFieldValue(
                    context,
                    size: 13,
                  ).copyWith(color: AppColors.createMuted, height: 1.4),
                ),
              ],
            ),
          ),
          SizedBox(height: Responsive.w(context, 16)),
          CreateAppCard(
            padding: EdgeInsets.zero,
            child: Column(
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
                  _PermissionRow(item: items[i]),
                  // Monetization: after first 2 permission rows
                  if (i == 1)
                    Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: Responsive.w(context, 8),
                      ),
                      child: const SmallNativeAdWidget(
                        placementId: AdPlacements.creationScreenNative,
                        includeOuterPadding: false,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionRow extends GetView<CreateAppController> {
  const _PermissionRow({required this.item});

  final _PermissionItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: Responsive.w(context, 16),
        vertical: Responsive.w(context, 16),
      ),
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
                asset: item.icon,
                size: Responsive.w(context, 19.995),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppTextStyles.createRowTitle(context)),
                Text(
                  item.subtitle,
                  style: AppTextStyles.createRowSubtitle(context),
                ),
              ],
            ),
          ),
          Obx(
            () => CreateToggle(
              value: controller.permissions[item.key] ?? false,
              onChanged: (v) => controller.togglePermission(item.key, v),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionItem {
  const _PermissionItem({
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
