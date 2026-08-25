import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/navigation/auth_redirect.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/ads/interstitial_ad_trigger.dart';
import 'package:web_to_app/core/services/build_login_gate.dart';
import 'package:web_to_app/core/services/build_quota_service.dart';
import 'package:web_to_app/core/services/credit_gate.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/models/build_models.dart';
import 'package:web_to_app/data/models/signing_models.dart';
import 'package:web_to_app/data/repositories/builds_repository.dart';
import 'package:web_to_app/data/repositories/signing_repository.dart';
import 'package:web_to_app/data/services/app_sync_service.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/home/controllers/home_controller.dart';
import 'package:web_to_app/modules/create_app/models/preview_mode.dart';
import 'package:web_to_app/modules/create_app/services/create_app_picker_service.dart';

class BuildAppController extends GetxController {
  final buildState = BuildState.ready.obs;
  final selectedFormats = <BuildFormat>{BuildFormat.apk, BuildFormat.aab}.obs;
  final signingMode = SigningMode.auto.obs;
  final buildNumberController = TextEditingController();
  final keystoreStorePasswordController = TextEditingController();
  final keystoreKeyAliasController = TextEditingController(text: 'upload');
  final keystoreKeyPasswordController = TextEditingController();
  final buildProgress = 0.0.obs;
  final logExpanded = false.obs;
  final downloadProgress = 0.0.obs;
  final estimatedWaitRemainingSeconds = 0.obs;
  final keystorePath = Rxn<String>();
  final keystoreFileName = Rxn<String>();
  final buildId = RxnString();
  final apkSizeLabel = '—'.obs;
  final isEnqueueing = false.obs;
  final isFetchingDownload = false.obs;
  final isPickingKeystore = false.obs;
  final isCancellingBuildExit = false.obs;
  final isLeavingBuildScreen = false.obs;
  final isSharingApp = false.obs;
  final downloadingFormat = Rxn<BuildFormat>();
  final sharingFormat = Rxn<BuildFormat>();

  final lastBuildError = RxnString();
  final buildLogs = <String>[r'$ Starting build process...'].obs;

  Timer? _pollTimer;
  Timer? _logsRetryTimer;
  Timer? _queueEstimateTimer;
  int _logsRetryCount = 0;
  static const _maxLogRetries = 10;
  String? _lastBuildStatus;
  String? _preparedAppId;
  String? _preparedAppVersionId;
  bool _hydratingExistingBuild = false;
  String? _creditChargedBuildId;
  DateTime? _queueEstimateEndsAt;
  int _queueEstimateTotalSeconds = 0;

  bool get isPostBuild =>
      buildState.value == BuildState.success ||
      buildState.value == BuildState.downloading ||
      buildState.value == BuildState.downloaded;

  bool get showApkCard => isPostBuild;

  List<BuildFormat> get selectedBuildFormats => [
    if (selectedFormats.contains(BuildFormat.apk)) BuildFormat.apk,
    if (selectedFormats.contains(BuildFormat.aab)) BuildFormat.aab,
  ];

  BuildFormat get primaryArtifactFormat =>
      selectedFormats.contains(BuildFormat.apk)
      ? BuildFormat.apk
      : BuildFormat.aab;

  bool get isBuildInProgress =>
      isEnqueueing.value || buildState.value == BuildState.building;

  bool get shouldConfirmBuildExit =>
      isBuildInProgress && !isLeavingBuildScreen.value;

  bool get shouldNavigateHomeOnBack {
    final appId = Get.find<CreateAppController>().appId.value;
    return appId != null && !shouldConfirmBuildExit;
  }

  String get buildStatusMessage {
    if (buildState.value == BuildState.failed) {
      return lastBuildError.value ?? 'build_failed'.tr;
    }
    final p = buildProgress.value;
    if (buildState.value == BuildState.success) return 'build_complete'.tr;
    if (p < 0.25) return 'build_queued'.tr;
    if (p < 0.5) return 'build_compiling'.tr;
    if (p < 0.8) return 'build_packaging'.tr;
    if (p < 1.0) return 'build_uploading'.tr;
    return 'build_complete'.tr;
  }

  void prepareForCurrentApp() {
    final create = Get.find<CreateAppController>();
    final appId = create.appId.value;
    final appVersionId = create.appVersionId.value;
    if (appId == null || appVersionId == null) return;

    final isSameContext =
        _preparedAppId == appId && _preparedAppVersionId == appVersionId;
    if (isSameContext) return;

    _preparedAppId = appId;
    _preparedAppVersionId = appVersionId;
    _resetBuildResult(resetFormats: true);
    _hydrateExistingBuild(appId);
  }

  Future<void> _hydrateExistingBuild(String appId) async {
    if (_hydratingExistingBuild) return;
    _hydratingExistingBuild = true;
    try {
      final builds = await Get.find<BuildsRepository>().listBuilds(appId);
      final sorted = List.of(builds)
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      BuildDto? latestSuccess;
      for (final build in sorted) {
        if (build.isSuccess) {
          latestSuccess = build;
          break;
        }
      }
      if (latestSuccess == null) return;

      buildId.value = latestSuccess.id;
      buildState.value = BuildState.success;
      buildProgress.value = 1.0;

      final formats = <BuildFormat>{};
      if ((latestSuccess.apkDownloadUrl ?? '').isNotEmpty) {
        formats.add(BuildFormat.apk);
      }
      if ((latestSuccess.aabDownloadUrl ?? '').isNotEmpty) {
        formats.add(BuildFormat.aab);
      }
      if (formats.isNotEmpty) {
        selectedFormats.assignAll(formats);
      }

      buildLogs.assignAll([
        r'$ Existing successful build found.',
        r'✓ Download is ready.',
      ]);
    } on ApiException catch (e) {
      if (e.code == 'network_error') {
        await AppErrorHandler.showNoInternetDialog(
          onRetry: () => _hydrateExistingBuild(appId),
        );
      }
    } finally {
      _hydratingExistingBuild = false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    _loadSigningState();
  }

  Future<void> _loadSigningState() async {
    final appId = Get.find<CreateAppController>().appId.value;
    if (appId == null) return;

    try {
      final signing = await Get.find<SigningRepository>().getSigning(appId);
      signingMode.value = signing.isUpload
          ? SigningMode.upload
          : SigningMode.auto;
    } catch (_) {}
  }

  void selectSigningMode(SigningMode mode) {
    if (buildState.value == BuildState.building) return;
    signingMode.value = mode;
    if (mode == SigningMode.auto) {
      clearKeystore();
    }
  }

  void toggleFormat(BuildFormat format) {
    if (isBuildInProgress || isPostBuild) return;
    if (selectedFormats.contains(format)) {
      if (selectedFormats.length > 1) {
        selectedFormats.remove(format);
      }
    } else {
      selectedFormats.add(format);
    }
    selectedFormats.refresh();
  }

  String artifactType(BuildFormat format) => switch (format) {
    BuildFormat.apk => 'apk',
    BuildFormat.aab => 'aab',
  };

  String artifactLabel(BuildFormat format) => switch (format) {
    BuildFormat.apk => 'APK',
    BuildFormat.aab => 'AAB',
  };

  void toggleLogExpanded() => logExpanded.value = !logExpanded.value;

  Future<void> _ensureSigningConfigured(String appId) async {
    final signingRepo = Get.find<SigningRepository>();

    if (signingMode.value == SigningMode.auto) {
      await signingRepo.setSigning(appId, const SetSigningRequest.auto());
      return;
    }

    final path = keystorePath.value;
    if (path == null) {
      throw ApiException(
        code: 'validation_error',
        message: 'upload_keystore_or_auto'.tr,
      );
    }

    final storePassword = keystoreStorePasswordController.text;
    final keyAlias = keystoreKeyAliasController.text.trim();
    final keyPassword = keystoreKeyPasswordController.text;

    if (storePassword.isEmpty || keyAlias.isEmpty || keyPassword.isEmpty) {
      throw ApiException(
        code: 'validation_error',
        message: 'enter_keystore_details'.tr,
      );
    }

    await signingRepo.setSigning(
      appId,
      SetSigningRequest.upload(
        keystorePassword: storePassword,
        keyAlias: keyAlias,
        keyPassword: keyPassword,
      ),
    );
    await signingRepo.uploadKeystoreFile(appId: appId, filePath: path);
  }

  Future<void> startBuild() async {
    if (!await BuildLoginGate.ensureForBuild(retry: startBuild)) {
      return;
    }

    if (!await CreditGate.ensureOrOpenPaywall()) {
      return;
    }

    // Generate Bundle & APK interstitial (RC: generatebundleapk_inter)
    await InterstitialAdTrigger.showGenerateBundleApkInterstitial();

    final create = Get.find<CreateAppController>();

    isEnqueueing.value = true;
    isLeavingBuildScreen.value = false;
    lastBuildError.value = null;
    buildProgress.value = 0.1;
    logExpanded.value = false;
    buildLogs.assignAll([
      r'$ Saving latest app config...',
      r'$ Configuring signing...',
      r'$ Enqueueing build...',
    ]);

    _pollTimer?.cancel();

    try {
      await Get.find<AppSyncService>().persistWizard(create);

      final appId = create.appId.value;
      final appVersionId = create.appVersionId.value;
      if (appId == null || appVersionId == null) {
        throw ApiException(
          code: 'validation_error',
          message: 'save_before_build'.tr,
        );
      }

      await _ensureSigningConfigured(appId);

      final buildsRepo = Get.find<BuildsRepository>();
      final build = await buildsRepo.enqueueBuild(
        appId: appId,
        appVersionId: appVersionId,
        idempotencyKey:
            '${appId}_${appVersionId}_${DateTime.now().millisecondsSinceEpoch}',
      );
      buildId.value = build.id;
      buildState.value = BuildState.building;
      _applyBuild(build);
      _startPolling(build.id);
    } on ApiException catch (e) {
      buildState.value = BuildState.ready;
      buildProgress.value = 0;
      if (e.code == 'no_entitlement') {
        AppToast.error('premium_required'.tr, description: e.message);
      } else {
        await AppErrorHandler.show(e, title: 'build_failed'.tr);
      }
    } catch (e) {
      buildState.value = BuildState.ready;
      buildProgress.value = 0;
      await AppErrorHandler.show(e, title: 'build_failed'.tr);
    } finally {
      isEnqueueing.value = false;
    }
  }

  void _startPolling(String id) {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 2), (_) async {
      try {
        final build = await Get.find<BuildsRepository>().getBuild(id);
        _applyBuild(build);
        if (build.isTerminal) {
          _pollTimer?.cancel();
          final logUrl = build.logUrl;
          if (build.isSuccess || (logUrl != null && logUrl.isNotEmpty)) {
            await _refreshLogs(id, logUrl: logUrl);
          }
        }
      } on ApiException catch (e) {
        if (e.statusCode == 401 || e.code == 'unauthenticated') {
          await _handleSessionExpired();
        }
      } catch (_) {
        // Keep polling on transient errors.
      }
    });
  }

  Future<void> _handleSessionExpired() async {
    _pollTimer?.cancel();
    _stopLogRetry();
    buildLogs.add(r'$ Session expired. Please sign in again.');
    buildLogs.refresh();

    final activeBuildId = buildId.value;
    AuthRedirect.setPendingAction(() async {
      if (activeBuildId != null) {
        _startPolling(activeBuildId);
      }
    });

    await Get.find<SessionService>().setGuest();
    AppToast.error(
      'Session expired',
      description: 'Sign in again to continue checking this build.',
    );
    await Get.toNamed(AppRoutes.auth);
  }

  void _applyBuild(BuildDto build) {
    final status = build.status;
    final statusChanged = _lastBuildStatus != status;
    _lastBuildStatus = status;
    final hasEstimatedProgress = (build.estimatedWaitSeconds ?? 0) > 0;

    switch (status) {
      case 'queued':
      case 'claimed':
        _startQueueEstimate(build.estimatedWaitSeconds);
        buildProgress.value = _queueEstimateProgress();
        if (statusChanged) buildLogs.add(r'$ Build queued...');
      case 'building':
        if (hasEstimatedProgress) {
          _startQueueEstimate(build.estimatedWaitSeconds);
          buildProgress.value = _queueEstimateProgress();
        } else {
          _stopQueueEstimate();
          buildProgress.value = 0.55;
        }
        if (statusChanged) buildLogs.add(r'$ Compiling resources...');
      case 'uploading':
        _stopQueueEstimate();
        buildProgress.value = 0.85;
        if (statusChanged) buildLogs.add(r'$ Uploading artifacts...');
      case 'succeeded':
        _stopQueueEstimate();
        buildProgress.value = 1.0;
        buildState.value = BuildState.success;
        if (statusChanged) {
          buildLogs.add(r'✓ Build successful!');
          unawaited(_consumeCreditOnBuildSuccess(build.id));
          unawaited(_markFirstBuildComplete());
        }
      case 'failed':
        if (statusChanged) {
          _stopQueueEstimate();
          final message = _friendlyBuildError(build.error);
          lastBuildError.value = message;
          buildState.value = BuildState.failed;
          logExpanded.value = true;
          buildLogs.add('✗ $message');
          AppToast.error(
            'build_failed'.tr,
            description: message,
          );
          _pollTimer?.cancel();
        }
      case 'canceled':
      case 'cancelled':
        if (statusChanged) {
          _stopQueueEstimate();
          buildState.value = BuildState.ready;
          buildProgress.value = 0;
          _pollTimer?.cancel();
        }
      default:
        break;
    }
    if (statusChanged) buildLogs.refresh();
  }

  String _friendlyBuildError(String? raw) {
    final value = (raw ?? '').trim();
    if (value.isEmpty) return 'build_failed_generic'.tr;
    final normalized =
        value.toLowerCase().replaceAll(RegExp(r'[_-]+'), ' ').trim();
    if (normalized == 'build error' ||
        normalized == 'build failed' ||
        normalized == 'unknown error' ||
        normalized == 'internal error') {
      return 'build_failed_generic'.tr;
    }
    return value;
  }

  void _startQueueEstimate(int? estimatedWaitSeconds) {
    final seconds = estimatedWaitSeconds ?? 0;
    if (seconds <= 0) {
      estimatedWaitRemainingSeconds.value = 0;
      return;
    }

    final newEndsAt = DateTime.now().add(Duration(seconds: seconds));
    final shouldRestart =
        _queueEstimateEndsAt == null ||
        newEndsAt.difference(_queueEstimateEndsAt!).abs() > const Duration(seconds: 3);

    if (shouldRestart) {
      _queueEstimateEndsAt = newEndsAt;
      _queueEstimateTotalSeconds = seconds;
      estimatedWaitRemainingSeconds.value = seconds;
      _queueEstimateTimer?.cancel();
      _queueEstimateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
        final endsAt = _queueEstimateEndsAt;
        if (endsAt == null) return;
        final remaining = endsAt.difference(DateTime.now()).inSeconds;
        estimatedWaitRemainingSeconds.value = remaining > 0 ? remaining : 0;
        buildProgress.value = _queueEstimateProgress();
        if (remaining <= 0) {
          _queueEstimateTimer?.cancel();
        }
      });
    }
  }

  double _queueEstimateProgress() {
    final total = _queueEstimateTotalSeconds;
    if (total <= 0) return 0.24;
    final remaining = estimatedWaitRemainingSeconds.value.clamp(0, total);
    final elapsedRatio = 1 - (remaining / total);
    return (0.12 + (elapsedRatio * 0.73)).clamp(0.12, 0.85);
  }

  void _stopQueueEstimate() {
    _queueEstimateTimer?.cancel();
    _queueEstimateTimer = null;
    _queueEstimateEndsAt = null;
    _queueEstimateTotalSeconds = 0;
    estimatedWaitRemainingSeconds.value = 0;
  }

  Future<void> _markFirstBuildComplete() async {
    await Get.find<TokenStorage>().markFirstBuildComplete();
    if (Get.isRegistered<HomeController>()) {
      unawaited(Get.find<HomeController>().loadApps());
    }
  }

  Future<void> _consumeCreditOnBuildSuccess(String id) async {
    if (_creditChargedBuildId == id) return;
    final consumed = await CreditGate.consumeAfterSuccess();
    if (consumed) {
      _creditChargedBuildId = id;
    }
  }

  Future<void> _refreshLogs(String id, {String? logUrl}) async {
    if (logUrl != null && logUrl.isNotEmpty) {
      _appendServerLogUrl(logUrl);
      return;
    }

    _logsRetryTimer?.cancel();
    _logsRetryCount = 0;
    await _tryFetchLogs(id);
  }

  void _appendServerLogUrl(String logUrl) {
    if (buildLogs.contains(logUrl)) return;
    buildLogs.add(r'$ Logs available at server');
    buildLogs.add(logUrl);
    buildLogs.refresh();
  }

  Future<void> _tryFetchLogs(String id) async {
    try {
      final logs = await Get.find<BuildsRepository>().getLogs(id);
      if (logs == null) {
        _scheduleLogRetry(id);
        return;
      }

      if (logs.logUrl.isNotEmpty) {
        _appendServerLogUrl(logs.logUrl);
      }
    } catch (_) {
      _scheduleLogRetry(id);
    }
  }

  void _scheduleLogRetry(String id) {
    if (_logsRetryCount >= _maxLogRetries) return;
    _logsRetryCount++;
    _logsRetryTimer?.cancel();
    _logsRetryTimer = Timer(const Duration(seconds: 3), () {
      unawaited(_tryFetchLogs(id));
    });
  }

  void _stopLogRetry() {
    _logsRetryTimer?.cancel();
    _logsRetryTimer = null;
    _logsRetryCount = 0;
  }

  Future<void> downloadArtifact(BuildFormat format) async {
    final id = buildId.value;
    if (id == null || buildState.value == BuildState.downloading) return;

    final isAab = format == BuildFormat.aab;
    final appId = Get.find<CreateAppController>().appId.value;
    // Paywall only on Download tap when free quota is over — nothing after download.
    if (!await BuildQuotaService.instance.ensureCanDownloadBundleApkOrOpenIap(
      isAab: isAab,
      appId: appId,
    )) {
      return;
    }

    isFetchingDownload.value = true;
    downloadingFormat.value = format;
    downloadProgress.value = 0.3;

    try {
      final artifact = await Get.find<BuildsRepository>().getArtifact(
        buildId: id,
        type: artifactType(format),
      );
      downloadProgress.value = 0.9;
      buildState.value = BuildState.downloading;
      final uri = Uri.parse(artifact.downloadUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      downloadProgress.value = 1.0;
      buildState.value = launched ? BuildState.downloaded : BuildState.success;
      if (launched) {
        await BuildQuotaService.instance.recordSuccessfulDownload(
          isAab: isAab,
          appId: appId,
        );
      } else {
        AppToast.info('download'.tr, description: 'could_not_open_download'.tr);
      }
    } on ApiException catch (e) {
      buildState.value = BuildState.success;
      downloadProgress.value = 0;
      await AppErrorHandler.show(e, title: 'download_failed'.tr);
    } finally {
      isFetchingDownload.value = false;
      downloadingFormat.value = null;
    }
  }

  Future<void> downloadApk() => downloadArtifact(BuildFormat.apk);

  Future<void> shareArtifact(BuildFormat format) async {
    final id = buildId.value;
    if (id == null || isSharingApp.value) return;

    isSharingApp.value = true;
    sharingFormat.value = format;
    try {
      final artifact = await Get.find<BuildsRepository>().getArtifact(
        buildId: id,
        type: artifactType(format),
      );
      final appName = Get.find<CreateAppController>().appNameController.text
          .trim();
      final title = appName.isEmpty ? 'Your app' : appName;
      final label = artifactLabel(format);

      await SharePlus.instance.share(
        ShareParams(
          title: title,
          subject: title,
          text: 'Download $title $label:\n${artifact.downloadUrl}',
        ),
      );
    } on ApiException catch (e) {
      await AppErrorHandler.show(e, title: 'Could not share app');
    } catch (e) {
      await AppErrorHandler.show(e, title: 'Could not share app');
    } finally {
      isSharingApp.value = false;
      sharingFormat.value = null;
    }
  }

  Future<void> shareApp() => shareArtifact(BuildFormat.apk);

  void buildAgain() {
    _resetBuildResult();
  }

  /// Build Again button — need credits available, then interstitial, then reset.
  Future<void> onBuildAgainTapped() async {
    if (!await BuildLoginGate.ensureForBuild(retry: onBuildAgainTapped)) {
      return;
    }

    if (!await CreditGate.ensureOrOpenPaywall()) {
      return;
    }

    await InterstitialAdTrigger.showBuildAgainInterstitial();
    buildAgain();
  }

  void resetForNewApp() {
    _preparedAppId = null;
    _preparedAppVersionId = null;
    _hydratingExistingBuild = false;
    selectedFormats.assignAll({BuildFormat.apk, BuildFormat.aab});
    signingMode.value = SigningMode.auto;
    clearKeystore();
    buildNumberController.clear();
    keystoreStorePasswordController.clear();
    keystoreKeyAliasController.text = 'upload';
    keystoreKeyPasswordController.clear();
    _resetBuildResult(resetFormats: true);
  }

  void _resetBuildResult({bool resetFormats = false}) {
    _pollTimer?.cancel();
    _stopLogRetry();
    _stopQueueEstimate();
    _lastBuildStatus = null;
    lastBuildError.value = null;
    isLeavingBuildScreen.value = false;
    buildState.value = BuildState.ready;
    buildProgress.value = 0;
    downloadProgress.value = 0;
    downloadingFormat.value = null;
    sharingFormat.value = null;
    isFetchingDownload.value = false;
    isSharingApp.value = false;
    logExpanded.value = false;
    buildId.value = null;
    apkSizeLabel.value = '—';
    if (resetFormats) {
      selectedFormats.assignAll({BuildFormat.apk, BuildFormat.aab});
    }
    buildLogs.assignAll([r'$ Starting build process...']);
  }

  void backToHome() {
    isLeavingBuildScreen.value = true;
    AppOpenAdManager.instance.blockNextResume();
    Get.offAllNamed(AppRoutes.home);
  }

  /// Go to Home after generate — interstitial then home (RC: gotohome_inter).
  Future<void> onGoToHomeTapped() async {
    await InterstitialAdTrigger.showPlacement(
      placementId: AdPlacements.goToHomeInter,
    );
    backToHome();
  }

  void editApp() => Get.back();

  Future<void> cancelBuildForExit() async {
    if (isCancellingBuildExit.value) return;

    isLeavingBuildScreen.value = true;
    isCancellingBuildExit.value = true;
    _pollTimer?.cancel();
    _stopLogRetry();
    _stopQueueEstimate();

    final id = buildId.value;
    try {
      if (id != null) {
        await Get.find<BuildsRepository>().cancelBuild(id);
      }
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.code == 'unauthenticated') {
        await _handleSessionExpired();
        return;
      }
      // The server may reject cancellation once a build is already in-flight.
      // Leaving still stops local polling so the user can return safely.
    } catch (_) {
      // Network failures should not trap the user on the build screen.
    } finally {
      buildState.value = BuildState.ready;
      buildProgress.value = 0;
      isCancellingBuildExit.value = false;
    }
  }

  Future<void> pickKeystore() async {
    if (isPickingKeystore.value) return;
    isPickingKeystore.value = true;
    try {
      final file = await CreateAppPickerService.pickKeystoreFile();
      if (file == null) return;
      keystorePath.value = file.path;
      keystoreFileName.value = file.name;
      signingMode.value = SigningMode.upload;
    } on PlatformException catch (e) {
      AppToast.error(
        'could_not_pick_file'.tr,
        description: e.message ?? 'keystore_file_hint'.tr,
      );
    } catch (e) {
      await AppErrorHandler.show(e, title: 'could_not_pick_file'.tr);
    } finally {
      isPickingKeystore.value = false;
    }
  }

  void clearKeystore() {
    keystorePath.value = null;
    keystoreFileName.value = null;
  }

  @override
  void onClose() {
    _pollTimer?.cancel();
    _stopLogRetry();
    _queueEstimateTimer?.cancel();
    buildNumberController.dispose();
    keystoreStorePasswordController.dispose();
    keystoreKeyAliasController.dispose();
    keystoreKeyPasswordController.dispose();
    super.onClose();
  }
}
