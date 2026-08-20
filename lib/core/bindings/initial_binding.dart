import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_remote_config_service.dart';
import 'package:web_to_app/core/api/api_client.dart';
import 'package:web_to_app/core/services/language_service.dart';
import 'package:web_to_app/core/services/push_notification_service.dart';
import 'package:web_to_app/core/services/premium_service.dart';
import 'package:web_to_app/core/services/session_service.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/data/repositories/apps_repository.dart';
import 'package:web_to_app/data/repositories/assets_repository.dart';
import 'package:web_to_app/data/repositories/auth_repository.dart';
import 'package:web_to_app/data/repositories/billing_repository.dart';
import 'package:web_to_app/data/repositories/builds_repository.dart';
import 'package:web_to_app/data/repositories/push_repository.dart';
import 'package:web_to_app/data/repositories/signing_repository.dart';
import 'package:web_to_app/data/services/app_open_service.dart';
import 'package:web_to_app/data/services/app_sync_service.dart';
import 'package:web_to_app/modules/splash/controllers/splash_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Sync services are registered in main() before runApp.
  }

  static Future<void> init() async {
    final tokenStorage = await TokenStorage.create();
    Get.put<TokenStorage>(tokenStorage, permanent: true);

    final apiClient = ApiClient(tokenStorage);
    await apiClient.init();
    Get.put<ApiClient>(apiClient, permanent: true);

    Get.put<AuthRepository>(
      AuthRepository(apiClient, tokenStorage),
      permanent: true,
    );
    Get.put<AppsRepository>(AppsRepository(apiClient), permanent: true);
    Get.put<AssetsRepository>(AssetsRepository(apiClient), permanent: true);
    Get.put<BuildsRepository>(BuildsRepository(apiClient), permanent: true);
    Get.put<SigningRepository>(SigningRepository(apiClient), permanent: true);
    Get.put<BillingRepository>(BillingRepository(apiClient), permanent: true);
    Get.put<PushRepository>(PushRepository(apiClient), permanent: true);

    final session = Get.put<SessionService>(SessionService(), permanent: true);

    PremiumService.onPremiumChanged = () {
      session.notifyIapPremiumChanged();
      if (Get.isRegistered<SplashController>()) {
        Get.find<SplashController>().markPremiumRestored();
      }
    };

    final languageService = Get.put<LanguageService>(
      LanguageService(),
      permanent: true,
    );
    await languageService.init();

    Get.put<AppSyncService>(
      AppSyncService(
        Get.find<AppsRepository>(),
        Get.find<AssetsRepository>(),
        session,
      ),
      permanent: true,
    );
    Get.put<AppOpenService>(
      AppOpenService(Get.find<AppsRepository>()),
      permanent: true,
    );

    final pushService = PushNotificationService(
      Get.find<PushRepository>(),
      session,
    );
    await pushService.init();
    Get.put<PushNotificationService>(pushService, permanent: true);

    await PremiumService.beginRestoreEarly();

    // Remote Config early; Mobile Ads + GDPR consent wait until UI exists
    // (see SplashController / AdService.initialize).
    await AdRemoteConfigService.instance.initialize();
  }
}
