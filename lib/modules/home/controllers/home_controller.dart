import 'dart:async';

import 'package:get/get.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/push_notification_service.dart';
import 'package:web_to_app/core/services/guest_auth_service.dart';
import 'package:web_to_app/core/services/guest_migration_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/data/repositories/builds_repository.dart';
import 'package:web_to_app/data/services/app_open_service.dart';
import 'package:web_to_app/modules/home/models/project_display_status.dart';

class HomeController extends GetxController {
  final RxInt selectedTab = 0.obs;
  final RxList<AppSummary> apps = <AppSummary>[].obs;
  final RxMap<String, AppBuildSnapshot> buildSnapshots =
      <String, AppBuildSnapshot>{}.obs;
  final RxBool isLoadingApps = false.obs;
  final RxString appsError = ''.obs;
  final RxnString openingAppId = RxnString();
  final RxnString appActionId = RxnString();

  static const recentLimit = 5;

  Timer? _statusPollTimer;

  List<AppSummary> get recentApps {
    final sorted = List<AppSummary>.from(apps)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(recentLimit).toList();
  }

  AppBuildSnapshot snapshotFor(String appId) =>
      buildSnapshots[appId] ?? const AppBuildSnapshot();

  Future<void> selectTab(int index) async {
    final isTabChange = selectedTab.value != index;
    selectedTab.value = index;
    if (index == 0 || index == 1) {
      loadApps();
    }
    if (isTabChange) {
      unawaited(
        AnalyticsService.instance.logBottomNav(
          AnalyticsService.tabNameForIndex(index),
        ),
      );
    }
  }

  Future<void> openMyAppsTab() => selectTab(1);

  @override
  void onInit() {
    super.onInit();
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _recoverGuestProjectsIfNeeded();
    await loadApps();
    await _requestNotificationPermission();
  }

  Future<void> _recoverGuestProjectsIfNeeded() async {
    final session = Get.find<SessionService>();
    if (!session.isAuthenticated) return;

    try {
      final created = await Get.find<GuestMigrationService>()
          .recoverGuestProjectsIfNeeded(Get.find<TokenStorage>());
      if (created > 0) {
        AppToast.success(
          'guest_projects_migrated'.tr,
          description: 'guest_projects_migrated_desc'
              .trParams({'count': '$created'}),
        );
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    _statusPollTimer?.cancel();
    super.onClose();
  }

  Future<void> _requestNotificationPermission() async {
    await Get.find<PushNotificationService>().requestPermissionIfNeeded();
  }

  Future<void> loadApps({bool silent = false}) async {
    final session = Get.find<SessionService>();
    if (session.isGuest.value) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();
    }
    if (!session.canAccessApps) {
      apps.clear();
      buildSnapshots.clear();
      _syncStatusPolling();
      return;
    }

    if (!silent) {
      isLoadingApps.value = true;
    }
    appsError.value = '';
    try {
      final summaries = await Get.find<AppsRepository>().listApps();
      apps.value = summaries;
      await _loadBuildSnapshots(summaries);
      _syncStatusPolling();
    } catch (e) {
      if (AppErrorHandler.isNetworkError(e)) {
        appsError.value = '';
        if (!silent) {
          await AppErrorHandler.showNoInternetDialog(onRetry: loadApps);
        }
      } else {
        appsError.value = AppErrorHandler.messageFor(e);
      }
    } finally {
      if (!silent) {
        isLoadingApps.value = false;
      }
    }
  }

  Future<void> _loadBuildSnapshots(List<AppSummary> summaries) async {
    if (summaries.isEmpty) {
      buildSnapshots.clear();
      return;
    }

    final buildsRepo = Get.find<BuildsRepository>();
    final entries = await Future.wait(
      summaries.map((summary) async {
        try {
          final builds = await buildsRepo.listBuilds(summary.id);
          return MapEntry(summary.id, AppBuildSnapshot.fromBuilds(builds));
        } catch (_) {
          return MapEntry(summary.id, const AppBuildSnapshot());
        }
      }),
    );

    buildSnapshots.assignAll(Map.fromEntries(entries));
  }

  void _syncStatusPolling() {
    final hasActiveBuild = buildSnapshots.values.any(
      (snapshot) => snapshot.hasActiveBuild,
    );

    if (hasActiveBuild) {
      _statusPollTimer ??= Timer.periodic(
        const Duration(seconds: 5),
        (_) => unawaited(_pollActiveBuildStatuses()),
      );
      return;
    }

    _statusPollTimer?.cancel();
    _statusPollTimer = null;
  }

  Future<void> _pollActiveBuildStatuses() async {
    final activeAppIds = buildSnapshots.entries
        .where((entry) => entry.value.hasActiveBuild)
        .map((entry) => entry.key)
        .toList();

    if (activeAppIds.isEmpty) {
      _syncStatusPolling();
      return;
    }

    final buildsRepo = Get.find<BuildsRepository>();
    var needsAppRefresh = false;

    for (final appId in activeAppIds) {
      try {
        final builds = await buildsRepo.listBuilds(appId);
        final snapshot = AppBuildSnapshot.fromBuilds(builds);
        buildSnapshots[appId] = snapshot;
        if (snapshot.latest?.isSuccess == true) {
          needsAppRefresh = true;
        }
      } catch (_) {}
    }

    if (needsAppRefresh) {
      try {
        apps.value = await Get.find<AppsRepository>().listApps();
      } catch (_) {}
    }

    _syncStatusPolling();
  }

  Future<void> openAppBuild(AppSummary app) async {
    final session = Get.find<SessionService>();
    if (session.isGuest.value) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();
    }
    if (!session.canAccessApps) {
      AppToast.info(
        'sign_in_required'.tr,
        description: 'sign_in_to_open_apps'.tr,
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
    if (session.isGuest.value) {
      await Get.find<GuestAuthService>().ensureGuestApiSession();
    }
    if (!session.canAccessApps) {
      AppToast.info(
        'sign_in_required'.tr,
        description: 'sign_in_to_open_apps'.tr,
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
      buildSnapshots.remove(app.id);
      _syncStatusPolling();
      AppToast.success('app_archived'.tr);
    } catch (e) {
      await AppErrorHandler.show(e);
    } finally {
      appActionId.value = null;
    }
  }
}
