import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';
import 'package:web_to_app/modules/home/models/recent_app.dart';

class RecentAppTile extends StatelessWidget {
  const RecentAppTile({
    super.key,
    required this.app,
    this.showDivider = true,
    this.onTap,
    this.onMoreTap,
    this.isLoading = false,
    this.isActionLoading = false,
  });

  final RecentApp app;
  final bool showDivider;
  final VoidCallback? onTap;
  final VoidCallback? onMoreTap;
  final bool isLoading;
  final bool isActionLoading;

  @override
  Widget build(BuildContext context) {
    final isBuilt = app.status == AppStatus.built;
    final statusColor = isBuilt ? AppColors.homeBuilt : AppColors.homeDraft;
    final statusBg = isBuilt ? AppColors.homeBuiltBg : AppColors.homeDraftBg;
    final statusIcon = isBuilt
        ? Icons.check_circle_rounded
        : Icons.schedule_rounded;
    final statusLabel = isBuilt ? 'built'.tr : 'draft'.tr;
    final iconSize = Responsive.w(context, 11.983);

    return Column(
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isLoading || isActionLoading ? null : onTap,
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 16),
                vertical: Responsive.w(context, 14),
              ),
              child: Row(
                children: [
                  Container(
                    width: Responsive.w(context, 39.99),
                    height: Responsive.w(context, 39.99),
                    decoration: BoxDecoration(
                      color: app.iconColor,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 10),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      app.initial,
                      style: AppTextStyles.homeAppInitial(context),
                    ),
                  ),
                  SizedBox(width: Responsive.w(context, 16)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.name,
                          style: AppTextStyles.homeAppName(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          app.url,
                          style: AppTextStyles.homeAppUrl(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (isLoading || isActionLoading)
                    SizedBox(
                      width: Responsive.w(context, 20),
                      height: Responsive.w(context, 20),
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  else ...[
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 8),
                        vertical: Responsive.w(context, 2),
                      ),
                      decoration: BoxDecoration(
                        color: statusBg,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(statusIcon, size: iconSize, color: statusColor),
                          SizedBox(width: Responsive.w(context, 4)),
                          Text(
                            statusLabel,
                            style: AppTextStyles.homeStatusBadge(
                              context,
                              statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onMoreTap == null) ...[
                      SizedBox(width: Responsive.w(context, 8)),
                      RtlFlip(
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: Responsive.w(context, 15.989),
                          color: AppColors.homeMuted,
                        ),
                      ),
                    ] else ...[
                      SizedBox(width: Responsive.w(context, 6)),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: onMoreTap,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: EdgeInsets.all(Responsive.w(context, 6)),
                            child: Icon(
                              Icons.more_vert_rounded,
                              size: Responsive.w(context, 18),
                              color: AppColors.homeMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: Responsive.w(context, 1.16),
            color: AppColors.homeBorder,
            indent: Responsive.w(context, 16),
            endIndent: Responsive.w(context, 16),
          ),
      ],
    );
  }
}
