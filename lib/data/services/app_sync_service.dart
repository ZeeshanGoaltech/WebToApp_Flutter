import 'package:get/get.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/data/mappers/app_config_mapper.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/data/repositories/assets_repository.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';

class AppSyncService extends GetxService {
  AppSyncService(
    this._appsRepository,
    this._assetsRepository,
    this._sessionService,
  );

  final AppsRepository _appsRepository;
  final AssetsRepository _assetsRepository;
  final SessionService _sessionService;

  Future<AppSyncResult> persistWizard(CreateAppController controller) async {
    if (!_sessionService.isAuthenticated) {
      throw ApiException(
        code: 'unauthenticated',
        message: 'Sign in to save and build your app.',
      );
    }

    String appId = controller.appId.value ?? '';
    final slideAssetIds = <String, String>{};

    if (appId.isEmpty) {
      final bootstrapConfig = AppConfigMapper.fromWizard(
        controller,
        iconAssetId: null,
        splashAssetId: null,
        slideAssetIds: const {},
      );
      final created = await _appsRepository.createApp(
        name: controller.appNameController.text.trim(),
        androidPackage: controller.packageNameController.text.trim(),
        config: bootstrapConfig,
      );
      appId = created.appId;
      controller.appId.value = appId;
      controller.configVersion.value = created.configVersion;
    }

    String? iconAssetId;
    if (controller.iconPath.value != null) {
      final uploaded = await _assetsRepository.uploadImage(
        appId: appId,
        filePath: controller.iconPath.value!,
        type: 'icon',
      );
      iconAssetId = uploaded.assetId;
    }

    String? splashAssetId;
    if (controller.splashPath.value != null) {
      final uploaded = await _assetsRepository.uploadImage(
        appId: appId,
        filePath: controller.splashPath.value!,
        type: 'splash',
      );
      splashAssetId = uploaded.assetId;
    }

    for (final slide in controller.slides) {
      if (slide.imagePath != null) {
        final uploaded = await _assetsRepository.uploadImage(
          appId: appId,
          filePath: slide.imagePath!,
          type: 'onboarding',
        );
        slideAssetIds[slide.id] = uploaded.assetId;
      }
    }

    final config = AppConfigMapper.fromWizard(
      controller,
      iconAssetId: iconAssetId,
      splashAssetId: splashAssetId,
      slideAssetIds: slideAssetIds,
    );

    final updated = await _appsRepository.putConfig(appId: appId, config: config);
    controller.configVersion.value = updated.configVersion;

    final version = await _appsRepository.getLatestVersion(appId);
    if (version == null) {
      throw ApiException(
        code: 'internal_error',
        message: 'Could not resolve app version after save.',
      );
    }

    controller.appVersionId.value = version.id;

    return AppSyncResult(
      appId: appId,
      appVersionId: version.id,
      configVersion: updated.configVersion,
    );
  }
}

class AppSyncResult {
  const AppSyncResult({
    required this.appId,
    required this.appVersionId,
    required this.configVersion,
  });

  final String appId;
  final String appVersionId;
  final int configVersion;
}
