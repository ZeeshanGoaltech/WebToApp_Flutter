import 'package:get/get.dart';
import 'package:web_to_app/modules/iap/controllers/iap_controller.dart';

class IapBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => IapController());
}
