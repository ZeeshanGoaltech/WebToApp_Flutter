import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/navigation/launch_flow.dart';
import 'package:web_to_app/core/services/token_storage.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/modules/intro/data/intro_data.dart';

class IntroController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  final RxBool nativeAdVisible = false.obs;
  DateTime? _lastBackPressAt;

  int get pageCount => IntroData.pageCount;

  void onNativeAdVisibilityChanged(bool visible) {
    nativeAdVisible.value = visible;
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void onNext() {
    if (currentPage.value < pageCount - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }
    _goHome();
  }

  void skip() {
    _goHome();
  }

  Future<void> _goHome() async {
    await Get.find<TokenStorage>().markOnboardingComplete();
    LaunchFlow.goAuthOrIap();
  }

  Future<bool> handleSystemBack() async {
    // Swallow while inter/app-open is up; do not permanently disable after X dismiss.
    if (AdPresentationGate.shouldBlockBack) return false;

    final now = DateTime.now();
    if (_lastBackPressAt == null ||
        now.difference(_lastBackPressAt!) > const Duration(seconds: 2)) {
      _lastBackPressAt = now;
      await AppToast.info('press_back_again_to_close'.tr);
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
