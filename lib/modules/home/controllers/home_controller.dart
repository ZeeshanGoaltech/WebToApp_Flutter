import 'dart:async';

import 'package:get/get.dart';
import 'package:web_to_app/core/ads/interstitial_ad_trigger.dart';
import 'package:web_to_app/core/services/push_notification_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/data/services/app_open_service.dart';

class HomeController extends GetxController {
  final RxInt selectedTab = 0.obs;
  final RxList<AppSummary> apps = <AppSummary>[].obs;
  final RxBool isLoadingApps = false.obs;
  final RxBool isExitSheetVisible = false.obs;
  final RxString appsError = ''.obs;
  final RxnString openingAppId = RxnString();
  final RxnString appActionId = RxnString();

  static const recentLimit = 2;

  List<AppSummary> get recentApps {
    final sorted = List<AppSummary>.from(apps)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(recentLimit).toList();
  }

  void selectTab(int index) {
    final isTabChange = selectedTab.value != index;
    selectedTab.value = index;
    if (index == 0 || index == 1) {
      loadApps();
    }
    // Bottom Click Inter (RC: project_native) — count every tab change.
    if (isTabChange) {
      unawaited(InterstitialAdTrigger.showBottomTabInterstitial());
    }
  }

  void openMyAppsTab() => selectTab(1);

  @override
  void onInit() {
    super.onInit();
    loadApps();
    _requestNotificationPermission();
  }

  Future<void> _requestNotificationPermission() async {
    await Get.find<PushNotificationService>().requestPermissionIfNeeded();
  }

  Future<void> loadApps() async {
    final session = Get.find<SessionService>();
    if (!session.isAuthenticated) {
      apps.clear();
      return;
    }

    isLoadingApps.value = true;
    appsError.value = '';
    try {
      apps.value = await Get.find<AppsRepository>().listApps();
    } catch (e) {
      if (AppErrorHandler.isNetworkError(e)) {
        appsError.value = '';
        await AppErrorHandler.showNoInternetDialog(onRetry: loadApps);
      } else {
        appsError.value = AppErrorHandler.messageFor(e);
      }
    } finally {
      isLoadingApps.value = false;
    }
  }

  Future<void> openAppBuild(AppSummary app) async {
    final session = Get.find<SessionService>();
    if (!session.isAuthenticated) {
      AppToast.info(
        'Sign in required',
        description: 'Sign in to open and build your apps.',
      );
      return;
    }

    if (openingAppId.value != null) return;

    openingAppId.value = app.id;
    try {
      await AppOpenService.openOrPrompt(app);
    } finally {
      openingAppId.value = null;
      await loadApps();
    }
  }

  Future<void> openAppBuildFlow(AppSummary app) async {
    final session = Get.find<SessionService>();
    if (!session.isAuthenticated) {
      AppToast.info(
        'Sign in required',
        description: 'Sign in to open and build your apps.',
      );
      return;
    }

    if (openingAppId.value != null) return;

    openingAppId.value = app.id;
    try {
      await Get.find<AppOpenService>().openBuildScreen(app);
    } catch (e) {
      await AppErrorHandler.show(e, title: 'could_not_open_app'.tr);
    } finally {
      openingAppId.value = null;
      await loadApps();
    }
  }

  Future<void> renameApp(AppSummary app, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      AppToast.info('missing_fields'.tr, description: 'app_name'.tr);
      return;
    }
    if (appActionId.value != null) return;

    appActionId.value = app.id;
    try {
      await Get.find<AppsRepository>().updateApp(appId: app.id, name: trimmed);
      AppToast.success('app_renamed'.tr);
      await loadApps();
    } catch (e) {
      await AppErrorHandler.show(e);
    } finally {
      appActionId.value = null;
    }
  }

  Future<void> archiveApp(AppSummary app) async {
    if (appActionId.value != null) return;

    appActionId.value = app.id;
    try {
      await Get.find<AppsRepository>().archiveApp(app.id);
      apps.removeWhere((item) => item.id == app.id);
      AppToast.success('app_archived'.tr);
    } catch (e) {
      await AppErrorHandler.show(e);
    } finally {
      appActionId.value = null;
    }
  }
}
