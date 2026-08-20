import 'package:get/get.dart';
import 'package:web_to_app/modules/iap/controllers/lifetime_premium_controller.dart';

class LifetimePremiumBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => LifetimePremiumController());
}
