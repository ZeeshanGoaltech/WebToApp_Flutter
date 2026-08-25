import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/medium_native_ad_widget.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/home/models/recent_app.dart';
import 'package:web_to_app/modules/home/widgets/recent_app_tile.dart';

class RecentSection extends GetView<HomeController> {
  const RecentSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: Responsive.w(context, 20)),
      child: Obx(() {
        final recentApps = controller.recentApps;
        final isLoading = controller.isLoadingApps.value;
        final error = controller.appsError.value;
        final openingId = controller.openingAppId.value;

        return _AppsListSection(
          title: 'recent'.tr,
          countLabel: '${recentApps.length}',
          actionLabel: 'see_all'.tr,
          onAction: controller.openMyAppsTab,
          apps: recentApps,
          isLoading: isLoading,
          error: error,
          openingAppId: openingId,
          actionAppId: controller.appActionId.value,
          onAppTap: controller.openAppBuild,
          onAppMoreTap: (app) => _showAppActions(context, controller, app),
          emptyMessage: 'no_apps_yet_home'.tr,
        );
      }),
    );
  }
}

class MyAppsTab extends GetView<HomeController> {
  const MyAppsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.homeBackground,
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
            child: Text(
              'my_apps'.tr,
              style: AppTextStyles.homeHeaderTitle(context),
            ),
          ),
          Expanded(
            child: Obx(() {
              final apps = List<AppSummary>.from(controller.apps)
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
              final session = Get.find<SessionService>();

              if (!session.canAccessApps) {
                return Center(
                  child: Padding(
                    padding: EdgeInsets.all(Responsive.w(context, 24)),
                    child: Text(
                      'sign_in_to_see_apps'.tr,
                      style: AppTextStyles.homeAppUrl(context),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 24),
                  0,
                  Responsive.w(context, 24),
                  Responsive.w(context, 32),
                ),
                child: _AppsListSection(
                  title: 'all_apps'.tr,
                  countLabel: '${apps.length}',
                  actionLabel: 'refresh'.tr,
                  onAction: controller.loadApps,
                  apps: apps,
                  isLoading: controller.isLoadingApps.value,
                  error: controller.appsError.value,
                  openingAppId: controller.openingAppId.value,
                  actionAppId: controller.appActionId.value,
                  onAppTap: controller.openAppBuild,
                  onAppMoreTap: (app) =>
                      _showAppActions(context, controller, app),
                  emptyMessage: 'no_apps_yet_myapps'.tr,
                  showHeader: true,
                  // Medium native: after 1st if only 1 app, else after 2nd (RC: myproj_native)
                  listAd: const MediumNativeAdWidget(
                    placementId: AdPlacements.myProjNative,
                    includeOuterPadding: false,
                  ),
                  listAdAfterCount: 2,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AppsListSection extends StatelessWidget {
  const _AppsListSection({
    required this.title,
    required this.countLabel,
    required this.apps,
    required this.isLoading,
    required this.error,
    required this.openingAppId,
    required this.actionAppId,
    required this.onAppTap,
    required this.onAppMoreTap,
    required this.emptyMessage,
    this.showHeader = true,
    this.actionLabel,
    this.onAction,
    this.listAd,
    this.listAdAfterCount = 2,
  });

  final String title;
  final String countLabel;
  final List<AppSummary> apps;
  final bool isLoading;
  final String error;
  final String? openingAppId;
  final String? actionAppId;
  final ValueChanged<AppSummary> onAppTap;
  final ValueChanged<AppSummary> onAppMoreTap;
  final String emptyMessage;
  final bool showHeader;
  final String? actionLabel;
  final VoidCallback? onAction;

  /// Optional native ad inserted in the list.
  /// When there is only 1 app, inserts after that card; otherwise after
  /// [listAdAfterCount] cards (default 2).
  final Widget? listAd;
  final int listAdAfterCount;

  @override
  Widget build(BuildContext context) {
    final borderWidth = Responsive.w(context, 1.16);
    final radius = Responsive.w(context, 18);
    final showAction = actionLabel != null && onAction != null && apps.isNotEmpty;

    return Column(
      children: [
        if (showHeader)
          Row(
            children: [
              FigmaSvgIcon(
                asset: AppAssets.navMyApps,
                size: Responsive.w(context, 15.989),
                color: AppColors.homeAccent,
                tinted: true,
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Text(title, style: AppTextStyles.homeSectionTitle(context)),
              SizedBox(width: Responsive.w(context, 8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: Responsive.w(context, 8),
                  vertical: Responsive.w(context, 2),
                ),
                decoration: BoxDecoration(
                  color: AppColors.homeAccentLight,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  countLabel,
                  style: AppTextStyles.homeSectionBadge(context),
                ),
              ),
              if (showAction) ...[
                const Spacer(),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onAction,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 4),
                        vertical: Responsive.w(context, 2),
                      ),
                      child: Text(
                        actionLabel!,
                        style: AppTextStyles.homeSeeAll(context),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        if (showHeader) SizedBox(height: Responsive.w(context, 12)),
        if (isLoading)
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 24)),
            child: const CircularProgressIndicator(),
          )
        else if (error.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(Responsive.w(context, 16)),
            child: Text(error, style: AppTextStyles.homeAppUrl(context)),
          )
        else if (apps.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 20),
              vertical: Responsive.w(context, 24),
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(
                color: AppColors.homeBorder,
                width: borderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.homeAccent.withValues(alpha: 0.04),
                  offset: Offset(0, Responsive.w(context, 2)),
                  blurRadius: Responsive.w(context, 14),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: Responsive.w(context, 56),
                  height: Responsive.w(context, 56),
                  decoration: BoxDecoration(
                    color: AppColors.homeAccentLight,
                    borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
                  ),
                  child: Icon(
                    Icons.history_rounded,
                    color: AppColors.homeAccent,
                    size: Responsive.w(context, 28),
                  ),
                ),
                SizedBox(height: Responsive.h(context, 14)),
                Text(
                  title,
                  style: AppTextStyles.homeSectionTitle(context),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: Responsive.h(context, 6)),
                Text(
                  emptyMessage,
                  style: AppTextStyles.homeAppUrl(
                    context,
                  ).copyWith(height: 1.45),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          _buildAppsWithOptionalAd(context, borderWidth: borderWidth, radius: radius),
      ],
    );
  }

  Widget _buildAppsWithOptionalAd(
    BuildContext context, {
    required double borderWidth,
    required double radius,
  }) {
    // 1 app → after 1st; 2+ apps → after [listAdAfterCount] (usually 2).
    final insertAfter = apps.length == 1
        ? 1
        : listAdAfterCount;
    final showAd = listAd != null && apps.isNotEmpty && apps.length >= insertAfter;
    final firstBatch = showAd ? apps.take(insertAfter).toList() : apps;
    final rest =
        showAd ? apps.skip(insertAfter).toList() : const <AppSummary>[];

    return Column(
      children: [
        _AppsCard(
          apps: firstBatch,
          borderWidth: borderWidth,
          radius: radius,
          openingAppId: openingAppId,
          actionAppId: actionAppId,
          onAppTap: onAppTap,
          onAppMoreTap: onAppMoreTap,
        ),
        if (showAd) ...[
          SizedBox(height: Responsive.w(context, 12)),
          listAd!,
          if (rest.isNotEmpty) SizedBox(height: Responsive.w(context, 12)),
        ],
        if (rest.isNotEmpty)
          _AppsCard(
            apps: rest,
            borderWidth: borderWidth,
            radius: radius,
            openingAppId: openingAppId,
            actionAppId: actionAppId,
            onAppTap: onAppTap,
            onAppMoreTap: onAppMoreTap,
          ),
      ],
    );
  }
}

class _AppsCard extends StatelessWidget {
  const _AppsCard({
    required this.apps,
    required this.borderWidth,
    required this.radius,
    required this.openingAppId,
    required this.actionAppId,
    required this.onAppTap,
    required this.onAppMoreTap,
  });

  final List<AppSummary> apps;
  final double borderWidth;
  final double radius;
  final String? openingAppId;
  final String? actionAppId;
  final ValueChanged<AppSummary> onAppTap;
  final ValueChanged<AppSummary> onAppMoreTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: AppColors.homeBorder,
          width: borderWidth,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.homeAccent.withValues(alpha: 0.06),
            offset: Offset(0, Responsive.w(context, 2)),
            blurRadius: Responsive.w(context, 16),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(apps.length, (index) {
          final summary = apps[index];
          return RecentAppTile(
            app: RecentApp.fromSummary(summary),
            showDivider: index < apps.length - 1,
            onTap: () => onAppTap(summary),
            isLoading: openingAppId == summary.id,
            isActionLoading: actionAppId == summary.id,
            onMoreTap: () => onAppMoreTap(summary),
          );
        }),
      ),
    );
  }
}

Future<void> _showAppActions(
  BuildContext context,
  HomeController controller,
  AppSummary app,
) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => _AppActionsSheet(controller: controller, app: app),
  );
}

class _AppActionsSheet extends StatelessWidget {
  const _AppActionsSheet({required this.controller, required this.app});

  final HomeController controller;
  final AppSummary app;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 16),
        0,
        Responsive.w(context, 16),
        bottom + Responsive.w(context, 16),
      ),
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 18)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.w(context, 24)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: Responsive.w(context, 24),
              offset: Offset(0, Responsive.w(context, 10)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              app.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.settingsHeaderTitle(context),
            ),
            SizedBox(height: Responsive.w(context, 4)),
            Text(app.androidPackage, style: AppTextStyles.homeAppUrl(context)),
            SizedBox(height: Responsive.w(context, 16)),
            _AppActionButton(
              icon: Icons.build_rounded,
              title: '${'edit'.tr} & ${'build_again'.tr}',
              color: AppColors.homeAccent,
              onTap: () async {
                Navigator.of(context).pop();
                await controller.openAppBuildFlow(app);
              },
            ),
            SizedBox(height: Responsive.w(context, 10)),
            _AppActionButton(
              icon: Icons.edit_rounded,
              title: 'rename_app'.tr,
              color: AppColors.homeAccent,
              onTap: () async {
                Navigator.of(context).pop();
                await _showRenameAppDialog(context, controller, app);
              },
            ),
            SizedBox(height: Responsive.w(context, 10)),
            _AppActionButton(
              icon: Icons.delete_outline_rounded,
              title: 'archive_app'.tr,
              color: AppColors.createDelete,
              onTap: () async {
                Navigator.of(context).pop();
                await _confirmDeleteApp(context, controller, app);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AppActionButton extends StatelessWidget {
  const _AppActionButton({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        child: Padding(
          padding: EdgeInsets.all(Responsive.w(context, 14)),
          child: Row(
            children: [
              Icon(icon, color: color, size: Responsive.w(context, 20)),
              SizedBox(width: Responsive.w(context, 12)),
              Text(
                title,
                style: AppTextStyles.settingsRowTitle(
                  context,
                ).copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _showRenameAppDialog(
  BuildContext context,
  HomeController controller,
  AppSummary app,
) async {
  final textController = TextEditingController(text: app.name);
  final result = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
      ),
      title: Text(
        'rename_app'.tr,
        style: AppTextStyles.settingsHeaderTitle(context),
      ),
      content: TextField(
        controller: textController,
        autofocus: true,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: 'app_name'.tr,
          filled: true,
          fillColor: AppColors.createFieldBg,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            borderSide: const BorderSide(color: AppColors.createFieldBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            borderSide: const BorderSide(color: AppColors.createFieldBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            borderSide: const BorderSide(color: AppColors.createAccent),
          ),
        ),
        onSubmitted: (_) =>
            Navigator.of(dialogContext).pop(textController.text),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: Text('home_exit_cancel'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(textController.text),
          child: Text('done'.tr),
        ),
      ],
    ),
  );
  textController.dispose();

  if (result != null) {
    await controller.renameApp(app, result);
  }
}

Future<void> _confirmDeleteApp(
  BuildContext context,
  HomeController controller,
  AppSummary app,
) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
      ),
      title: Text(
        'archive_app'.tr,
        style: AppTextStyles.settingsHeaderTitle(context),
      ),
      content: Text(
        'archive_app_confirm'.tr,
        style: AppTextStyles.createRowSubtitle(context),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: Text('home_exit_cancel'.tr),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: Text(
            'archive_app'.tr,
            style: const TextStyle(color: AppColors.createDelete),
          ),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    await controller.archiveApp(app);
  }
}
