import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/controllers/build_app_controller.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';

class CreateAppBinding extends Bindings {
  @override
  void dependencies() {
    ensureCreateApp();
    if (!Get.isRegistered<BuildAppController>()) {
      Get.lazyPut<BuildAppController>(() => BuildAppController());
    }
  }

  /// Ensures [CreateAppController] exists as a live instance (not only a lazy
  /// factory). Safe to call from views/services after deletes or route races.
  static CreateAppController ensureCreateApp() {
    try {
      if (Get.isRegistered<CreateAppController>()) {
        return Get.find<CreateAppController>();
      }
    } catch (_) {
      try {
        Get.delete<CreateAppController>(force: true);
      } catch (_) {}
    }

    if (!Get.isRegistered<CreateAppController>()) {
      Get.lazyPut<CreateAppController>(() => CreateAppController());
    }
    return Get.find<CreateAppController>();
  }

  /// Non-throwing lookup used by build UI / controller helpers.
  static CreateAppController? createAppOrNull() {
    try {
      if (!Get.isRegistered<CreateAppController>()) return null;
      return Get.find<CreateAppController>();
    } catch (_) {
      return null;
    }
  }

  /// Reset wizard state for a brand-new app without starting controllers.
  ///
  /// `Get.isRegistered` is true for lazy factories that were never created.
  /// Finding `BuildAppController` in that state runs `onInit` and crashes if
  /// `CreateAppController` is missing.
  static void resetForNewAppIfPresent() {
    if (_isCreated<CreateAppController>()) {
      Get.find<CreateAppController>().resetForNewApp();
    }

    if (!Get.isRegistered<BuildAppController>()) return;

    if (_isCreated<BuildAppController>()) {
      Get.find<BuildAppController>().resetForNewApp();
      return;
    }

    if (!Get.isRegistered<CreateAppController>()) {
      Get.delete<BuildAppController>(force: true);
    }
  }

  static bool _isCreated<T>() =>
      Get.isRegistered<T>() && !Get.isPrepared<T>();
}
