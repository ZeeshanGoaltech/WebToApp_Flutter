import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/localization/l10n.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';

class AddTabSheet extends GetView<CreateAppController> {
  const AddTabSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(Responsive.w(context, 24)),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        Responsive.w(context, 12),
        Responsive.w(context, 24),
        Responsive.w(context, 32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: Responsive.w(context, 40),
              height: Responsive.w(context, 4),
              decoration: BoxDecoration(
                color: AppColors.createFieldBorder,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          SizedBox(height: Responsive.w(context, 16)),
          Text('add_tab'.tr, style: AppTextStyles.createSectionTitle(context)),
          SizedBox(height: Responsive.w(context, 16)),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: Responsive.w(context, 12),
            crossAxisSpacing: Responsive.w(context, 12),
            childAspectRatio: 1.4,
            children: [
              _TabOption(
                icon: CreateAppAssets.home,
                label: L10n.navTabLabel(NavTabType.home),
                onTap: () => _add(context, NavTabType.home),
              ),
              _TabOption(
                icon: CreateAppAssets.shield,
                label: L10n.navTabLabel(NavTabType.privacyPolicy),
                onTap: () => _add(context, NavTabType.privacyPolicy),
              ),
              _TabOption(
                icon: CreateAppAssets.whatsapp,
                label: L10n.navTabLabel(NavTabType.whatsapp),
                onTap: () => _add(context, NavTabType.whatsapp),
              ),
              _TabOption(
                icon: CreateAppAssets.externalLink,
                label: L10n.navTabLabel(NavTabType.externalLink),
                onTap: () => _add(context, NavTabType.externalLink),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _add(BuildContext context, NavTabType type) {
    controller.addTab(type);
    Get.back();
  }
}

class _TabOption extends StatelessWidget {
  const _TabOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final String icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        child: Ink(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.createFieldBorder, width: 1.16),
            borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: Responsive.w(context, 39.99),
                height: Responsive.w(context, 39.99),
                decoration: BoxDecoration(
                  color: AppColors.createAccentLight,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: FigmaSvgIcon(
                    asset: icon,
                    size: Responsive.w(context, 19.995),
                  ),
                ),
              ),
              SizedBox(height: Responsive.w(context, 8)),
              Text(
                label,
                style: AppTextStyles.createFieldValue(context, size: 13),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
