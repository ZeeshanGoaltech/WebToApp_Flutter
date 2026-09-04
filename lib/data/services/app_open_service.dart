import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/data/models/app_models.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/modules/create_app/bindings/create_app_binding.dart';
import 'package:web_to_app/modules/create_app/controllers/build_app_controller.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';

class AppOpenService extends GetxService {
  AppOpenService(this._appsRepository);

  final AppsRepository _appsRepository;

  /// Opens an existing app's build screen (no credit gate — gated on build actions).
  Future<void> openBuildScreen(AppSummary summary) async {
    await _prepareExistingApp(summary);
    await Get.toNamed(AppRoutes.buildApp);
  }

  Future<void> openEditor(AppSummary summary) async {
    await _prepareExistingApp(summary);
    await Get.toNamed(AppRoutes.createApp);
  }

  String _readStartUrl(Map<String, dynamic> config) {
    final identity = config['identity'] as Map<String, dynamic>?;
    final url = identity?['startUrl'] as String?;
    if (url != null && url.isNotEmpty) return url;

    final pages = config['pages'] as List<dynamic>?;
    if (pages != null && pages.isNotEmpty) {
      final first = pages.first as Map<String, dynamic>;
      final remote = first['remote'] as Map<String, dynamic>?;
      final pageUrl = remote?['url'] as String?;
      if (pageUrl != null && pageUrl.isNotEmpty) return pageUrl;
    }

    return '';
  }

  Future<void> _prepareExistingApp(AppSummary summary) async {
    final configResponse = await _appsRepository.getConfig(summary.id);
    final version = configResponse.version;

    if (Get.isRegistered<CreateAppController>()) {
      Get.delete<CreateAppController>(force: true);
    }
    if (Get.isRegistered<BuildAppController>()) {
      Get.delete<BuildAppController>(force: true);
    }

    CreateAppBinding().dependencies();
    final create = CreateAppBinding.ensureCreateApp();
    create.prepareForExistingApp(
      appId: summary.id,
      appVersionId: version.id,
      configVersion: 1,
      name: summary.name,
      androidPackage: summary.androidPackage,
      startUrl: _readStartUrl(configResponse.config),
      versionName: version.versionName,
      versionCode: version.androidVersionCode,
    );
  }

  static Future<void> openOrPrompt(AppSummary summary) async {
    await Get.find<AppOpenService>().openBuildScreen(summary);
  }
}
