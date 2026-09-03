import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/constants/app_feature_flags.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/modules/home/widgets/exit_bottom_sheet.dart';
import 'package:web_to_app/modules/home/widgets/exit_lifetime_sheet.dart';

/// Handles Android back on the home screen before the app closes.
abstract final class ShellBack {
  static bool _exitSheetVisible = false;
  static bool _exitSheetOpening = false;
  static DateTime? _exitSheetDismissedAt;
  static DateTime? _exitSheetShownAt;

  static bool get _recentlyDismissedExitSheet {
    final dismissedAt = _exitSheetDismissedAt;
    if (dismissedAt == null) return false;
    return DateTime.now().difference(dismissedAt) <
        const Duration(milliseconds: 450);
  }

  /// Returns true when the back press was handled.
  static Future<bool> handle(BuildContext context) async {
    // Inter / app-open load+show, plus brief post-dismiss grace for trailing back.
    if (AdPresentationGate.shouldBlockBack) {
      return true;
    }

    final route = Get.currentRoute;
    if (route == AppRoutes.lifetimePremium ||
        route == AppRoutes.downloadInApp ||
        route == AppRoutes.iap ||
        route == AppRoutes.creditsPack) {
      return true;
    }

    if (_exitSheetVisible) {
      final shownAt = _exitSheetShownAt;
      final openLongEnough = shownAt != null &&
          DateTime.now().difference(shownAt) >
              const Duration(milliseconds: 350);
      if (openLongEnough) {
        _dismissExitSheet(context);
      }
      return true;
    }

    if (_exitSheetOpening || _recentlyDismissedExitSheet) {
      return true;
    }

    await _showExitSheet(context);
    return true;
  }

  static void _dismissExitSheet(BuildContext context) {
    if (!_exitSheetVisible) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  static Future<void> _showExitSheet(BuildContext context) async {
    if (_exitSheetVisible || _exitSheetOpening) return;

    _exitSheetOpening = true;
    final navigator = Navigator.of(context, rootNavigator: true);
    await SchedulerBinding.instance.endOfFrame;
    _exitSheetOpening = false;

    final sheetContext = navigator.context;
    if (!sheetContext.mounted || _exitSheetVisible) return;

    final isPremium = Get.isRegistered<SessionService>()
        ? Get.find<SessionService>().hasPremiumAccess
        : PremiumService.isPremiumCached;
    final showLifetimeOffer =
        AppFeatureFlags.exitLifetimeOfferEnabled && !isPremium;

    _exitSheetVisible = true;
    _exitSheetShownAt = DateTime.now();
    String? action;
    var shouldExit = false;
    try {
      if (showLifetimeOffer) {
        action = await showModalBottomSheet<String>(
          context: sheetContext,
          useRootNavigator: true,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withAlpha(115),
          builder: (context) => const ExitLifetimeSheet(),
        );
        shouldExit = action == 'exit';
      } else {
        final result = await showModalBottomSheet<bool>(
          context: sheetContext,
          useRootNavigator: true,
          isScrollControlled: true,
          isDismissible: true,
          enableDrag: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withAlpha(115),
          builder: (context) => const ExitBottomSheet(),
        );
        shouldExit = result == true;
      }
    } finally {
      _exitSheetVisible = false;
      _exitSheetShownAt = null;
      _exitSheetDismissedAt = DateTime.now();
    }

    if (!sheetContext.mounted) return;

    if (action == 'stay') {
      await Get.toNamed(AppRoutes.lifetimePremium);
      return;
    }

    if (shouldExit) {
      if (Platform.isAndroid) {
        await SystemNavigator.pop();
      } else {
        exit(0);
      }
    }
  }
}
