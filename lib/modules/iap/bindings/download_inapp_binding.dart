import 'package:get/get.dart';
import 'package:web_to_app/modules/iap/controllers/download_inapp_controller.dart';

class DownloadInappBinding extends Bindings {
  @override
  void dependencies() => Get.lazyPut(() => DownloadInappController());
}
