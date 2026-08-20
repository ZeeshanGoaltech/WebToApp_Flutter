import 'package:get/get.dart';
import 'package:web_to_app/modules/create_app/controllers/build_app_controller.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';

class CreateAppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CreateAppController>(() => CreateAppController());
    Get.lazyPut<BuildAppController>(() => BuildAppController());
  }
}
