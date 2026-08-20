import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AppErrorHandler {
  AppErrorHandler._();

  static bool _isNoInternetDialogOpen = false;

  static bool isNetworkError(Object error) =>
      error is ApiException && error.code == 'network_error';

  static String messageFor(Object error) {
    if (error is ApiException) return error.message;
    return error.toString().replaceFirst(RegExp(r'^Exception:\s*'), '').trim();
  }

  static Future<void> show(
    Object error, {
    String? title,
    Future<void> Function()? onRetry,
  }) async {
    if (isNetworkError(error)) {
      await showNoInternetDialog(onRetry: onRetry);
      return;
    }

    await AppToast.error(title ?? 'request_failed'.tr, description: messageFor(error));
  }

  static Future<void> showNoInternetDialog({
    Future<void> Function()? onRetry,
  }) async {
    if (_isNoInternetDialogOpen) return;
    final context = Get.context;
    if (context == null) return;

    _isNoInternetDialogOpen = true;
    await Get.dialog<void>(
      Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
        backgroundColor: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(Responsive.w(context, 22)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(context, 28)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: Responsive.w(context, 32),
                offset: Offset(0, Responsive.w(context, 12)),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: Responsive.w(context, 60),
                height: Responsive.w(context, 60),
                decoration: BoxDecoration(
                  color: AppColors.homeAccentLight,
                  borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
                ),
                child: Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.homeAccent,
                  size: Responsive.w(context, 30),
                ),
              ),
              SizedBox(height: Responsive.h(context, 16)),
              Text(
                'no_internet_title'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.settingsHeaderTitle(context),
              ),
              SizedBox(height: Responsive.h(context, 8)),
              Text(
                'no_internet_desc'.tr,
                textAlign: TextAlign.center,
                style: AppTextStyles.createRowSubtitle(context).copyWith(height: 1.45),
              ),
              SizedBox(height: Responsive.h(context, 22)),
              Row(
                children: [
                  Expanded(
                    child: _DialogButton(
                      label: 'home_exit_cancel'.tr,
                      background: AppColors.createFieldBg,
                      foreground: AppColors.createMuted,
                      onTap: () => Get.back<void>(),
                    ),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(width: Responsive.w(context, 12)),
                    Expanded(
                      child: _DialogButton(
                        label: 'refresh'.tr,
                        background: AppColors.homeAccent,
                        foreground: Colors.white,
                        onTap: () async {
                          Get.back<void>();
                          await onRetry();
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
    _isNoInternetDialogOpen = false;
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
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
