import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/small_native_ad_widget.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_labeled_field.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_optional_badge.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_upload_zone.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';

class Step1IdentityPage extends GetView<CreateAppController> {
  const Step1IdentityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
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
                Text(
                  'app_identity'.tr,
                  style: AppTextStyles.createSectionTitle(context),
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() => CreateLabeledField(
                      label: 'website_url'.tr,
                      controller: controller.websiteUrlController,
                      hint: 'website_url_placeholder'.tr,
                      errorText: controller.errorFor('url'),
                      keyboardType: TextInputType.url,
                    )),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() => CreateLabeledField(
                      label: 'app_name'.tr,
                      controller: controller.appNameController,
                      hint: 'app_name_hint'.tr,
                      errorText: controller.errorFor('appName'),
                    )),
              ],
            ),
          ),
          SizedBox(height: Responsive.w(context, 24)),
          const SmallNativeAdWidget(
            placementId: AdPlacements.creationScreenNative,
            includeOuterPadding: false,
          ),
          SizedBox(height: Responsive.w(context, 24)),
          CreateAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _labeledRow(context, 'app_icon'.tr),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() {
                  final path = controller.iconPath.value;
                  if (path != null) {
                    return CreateImagePreview(
                      imagePath: path,
                      onRemove: controller.clearIcon,
                    );
                  }
                  return CreateUploadZone(
                    label: 'upload_icon'.tr,
                    onTap: controller.pickAppIcon,
                    isLoading: controller.isPickingIcon.value,
                  );
                }),
                SizedBox(height: Responsive.w(context, 16)),
                _labeledRow(context, 'splash_image'.tr),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() {
                  final path = controller.splashPath.value;
                  if (path != null) {
                    return CreateImagePreview(
                      imagePath: path,
                      height: Responsive.w(context, 127.984),
                      fit: BoxFit.cover,
                      onRemove: controller.clearSplash,
                    );
                  }
                  return CreateUploadZone(
                    label: 'upload_image'.tr,
                    onTap: controller.pickSplashImage,
                    isLoading: controller.isPickingSplash.value,
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: Responsive.w(context, 24)),
          CreateAppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'technical'.tr,
                  style: AppTextStyles.createSectionTitle(context),
                ),
                SizedBox(height: Responsive.w(context, 16)),
                Obx(() => CreateLabeledField(
                      label: 'package_name'.tr,
                      controller: controller.packageNameController,
                      hint: 'com.myapp.awesome',
                      monospace: true,
                      errorText: controller.errorFor('packageName'),
                    )),
                SizedBox(height: Responsive.w(context, 16)),
                Row(
                  children: [
                    Expanded(
                      child: Obx(() => CreateLabeledField(
                            label: 'version_code'.tr,
                            controller: controller.versionCodeController,
                            hint: '1',
                            errorText: controller.errorFor('versionCode'),
                            keyboardType: TextInputType.number,
                          )),
                    ),
                    SizedBox(width: Responsive.w(context, 8)),
                    Expanded(
                      child: Obx(() => CreateLabeledField(
                            label: 'version_name'.tr,
                            controller: controller.versionNameController,
                            hint: '1.0.0',
                            errorText: controller.errorFor('versionName'),
                          )),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _labeledRow(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppTextStyles.createFieldValue(context, size: 14)),
        const CreateOptionalBadge(),
      ],
    );
  }
}
