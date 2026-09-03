import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/controllers/build_app_controller.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';

class CreateAppBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<CreateAppController>()) {
      Get.lazyPut<CreateAppController>(() => CreateAppController());
    }
    // Start CreateApp first so BuildApp never initializes alone.
    Get.find<CreateAppController>();
    if (!Get.isRegistered<BuildAppController>()) {
      Get.lazyPut<BuildAppController>(() => BuildAppController());
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
