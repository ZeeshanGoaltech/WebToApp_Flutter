import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/medium_native_ad_widget.dart';
import 'package:web_to_app/core/constants/settings_assets.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/home/widgets/create_app_card.dart';
import 'package:web_to_app/modules/home/widgets/recent_section.dart';

class DashboardTab extends StatelessWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: AppColors.homeBackground,
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: Responsive.w(context, 24) + bottomInset,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                Responsive.w(context, 24),
                Responsive.w(context, 24),
                Responsive.w(context, 24),
                Responsive.w(context, 16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Web to App',
                      style: AppTextStyles.homeHeaderTitle(context),
                    ),
                  ),
                  const _HomeProIcon(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 24),
              ),
              child: const CreateAppCard(),
            ),
            // Medium native after first card (RC: home_native)
            const MediumNativeAdWidget(
              placementId: AdPlacements.homeNative,
            ),
            SizedBox(height: Responsive.h(context, 24)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 24),
              ),
              child: const RecentSection(),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeProIcon extends StatelessWidget {
  const _HomeProIcon();

  @override
  Widget build(BuildContext context) {
    final session = Get.find<SessionService>();

    return Obx(() {
      if (session.hasPremiumAccess) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(left: Responsive.w(context, 8)),
        child: Material(
          color: Colors.transparent,
          elevation: 4,
          shadowColor: const Color(0xFFFF9500).withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(Responsive.w(context, 999)),
          child: InkWell(
            onTap: LaunchFlow.openIapFromSettings,
            borderRadius: BorderRadius.circular(Responsive.w(context, 999)),
            child: Ink(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 14),
                vertical: Responsive.w(context, 9),
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFF9500), Color(0xFFFF7A00)],
                ),
                borderRadius: BorderRadius.circular(Responsive.w(context, 999)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FigmaSvgIcon(
                    asset: SettingsAssets.crown,
                    size: Responsive.w(context, 18),
                  ),
                  SizedBox(width: Responsive.w(context, 6)),
                  Text(
                    'pro'.tr,
                    style: AppTextStyles.settingsPremiumBadge(context).copyWith(
                      fontSize: Responsive.sp(context, 14),
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
