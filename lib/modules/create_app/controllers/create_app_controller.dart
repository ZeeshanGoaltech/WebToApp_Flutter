import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/core/localization/l10n.dart';
import 'package:web_to_app/core/api/api_exception.dart';
import 'package:web_to_app/core/services/build_quota_service.dart';
import 'package:web_to_app/core/utils/app_error_handler.dart';
import 'package:web_to_app/core/utils/app_toast.dart';
import 'package:web_to_app/data/services/app_sync_service.dart';
import 'package:web_to_app/modules/create_app/data/create_app_defaults.dart';
import 'package:web_to_app/modules/create_app/data/create_app_validator.dart';
import 'package:web_to_app/modules/create_app/models/nav_tab_model.dart';
import 'package:web_to_app/modules/create_app/models/onboarding_slide_model.dart';
import 'package:web_to_app/modules/create_app/models/preview_mode.dart';
import 'package:web_to_app/modules/create_app/services/create_app_picker_service.dart';

class CreateAppController extends GetxController {
  final pageController = PageController();
  final currentStep = 0.obs;

  final websiteUrlController = TextEditingController();
  final appNameController = TextEditingController();
  final packageNameController = TextEditingController();
  final versionCodeController = TextEditingController();
  final versionNameController = TextEditingController();

  final fieldErrors = <String, String>{}.obs;

  final iconPath = Rxn<String>();
  final splashPath = Rxn<String>();

  final bottomNavEnabled = true.obs;
  final navTabs = CreateAppDefaults.defaultNavTabs().obs;

  final pullToRefresh = false.obs;
  final desktopMode = false.obs;
  final keepScreenAlive = false.obs;

  final onboardingEnabled = true.obs;
  final slides = CreateAppDefaults.defaultSlides().obs;
  final currentSlideIndex = 0.obs;

  final permissions =
      Map<String, bool>.from(CreateAppDefaults.defaultPermissions).obs;

  final extraFeatures =
      Map<String, bool>.from(CreateAppDefaults.defaultExtraFeatures).obs;

  final selectedThemeColor = CreateAppDefaults.themeColors.first.obs;
  final darkStatusBar = false.obs;

  final previewMode = PreviewMode.splash.obs;

  final appId = RxnString();
  final appVersionId = RxnString();
  final configVersion = Rxn<int>();
  final isSaving = false.obs;

  static const stepCount = 6;
  String get title => L10n.stepTitles()[currentStep.value];
  String get ctaLabel => L10n.stepCtas()[currentStep.value];

  OnboardingSlideModel get currentSlide => slides[currentSlideIndex.value];

  bool get canAddSlide {
    if (slides.isEmpty) return false;
    return CreateAppValidator.isSlideComplete(slides.last);
  }

  void notifySlideChanged() => slides.refresh();

  String? errorFor(String key) => fieldErrors[key];

  void onPageChanged(int index) {
    currentStep.value = index;
    fieldErrors.clear();
  }

  void back() {
    if (currentStep.value == 0) {
      Get.back();
    } else {
      fieldErrors.clear();
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void next() async {
    if (!validateCurrentStep()) return;

    if (currentStep.value >= stepCount - 1) {
      await _saveAndOpenBuild();
      return;
    }
    fieldErrors.clear();
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _saveAndOpenBuild() async {
    if (!await BuildQuotaService.instance.ensureCanOpenBuildFlowOrOpenIap()) {
      return;
    }

    isSaving.value = true;
    try {
      await Get.find<AppSyncService>().persistWizard(this);
      Get.toNamed(AppRoutes.buildApp);
    } on ApiException catch (e) {
      await AppErrorHandler.show(e, title: 'could_not_save_app'.tr);
    } finally {
      isSaving.value = false;
    }
  }
  bool validateCurrentStep() {
    fieldErrors.clear();
    return switch (currentStep.value) {
      0 => _validateStep1(),
      2 => _validateStep3(),
      _ => true,
    };
  }

  bool _validateStep1() {
    var valid = true;

    void setError(String key, String? message) {
      if (message != null) {
        fieldErrors[key] = message;
        valid = false;
      }
    }

    setError('url', CreateAppValidator.validateWebsiteUrl(websiteUrlController.text));
    setError('appName', CreateAppValidator.validateAppName(appNameController.text));
    setError(
      'packageName',
      CreateAppValidator.validatePackageName(packageNameController.text),
    );
    setError(
      'versionCode',
      CreateAppValidator.validateVersionCode(versionCodeController.text),
    );
    setError(
      'versionName',
      CreateAppValidator.validateVersionName(versionNameController.text),
    );

    fieldErrors.refresh();
    return valid;
  }

  bool _validateStep3() {
    if (!onboardingEnabled.value) return true;

    var valid = true;
    for (var i = 0; i < slides.length; i++) {
      final slide = slides[i];
      final titleError = CreateAppValidator.validateSlideTitle(slide.title);
      if (titleError != null) {
        fieldErrors['slideTitle_$i'] = titleError;
        valid = false;
      }
      if (slide.ctaEnabled) {
        final ctaError = CreateAppValidator.validateCtaLabel(slide.ctaLabel);
        if (ctaError != null) {
          fieldErrors['slideCta_$i'] = ctaError;
          valid = false;
        }
      }
    }
    fieldErrors.refresh();
    return valid;
  }

  void suggestPackageName() {
    final name = appNameController.text.trim().toLowerCase();
    if (name.isEmpty) {
      fieldErrors['appName'] = 'err_enter_app_name_first'.tr;
      fieldErrors.refresh();
      return;
    }
    final slug = name.replaceAll(RegExp(r'[^a-z0-9]+'), '');
    if (slug.isEmpty) {
      fieldErrors['packageName'] = 'err_app_name_letters'.tr;
      fieldErrors.refresh();
      return;
    }
    packageNameController.text = 'com.$slug';
    fieldErrors.remove('packageName');
    fieldErrors.refresh();
  }

  void clearIcon() => iconPath.value = null;
  void clearSplash() => splashPath.value = null;

  Future<void> pickAppIcon() async {
    final path = await CreateAppPickerService.pickImageFromGallery();
    if (path != null) iconPath.value = path;
  }

  Future<void> pickSplashImage() async {
    final path = await CreateAppPickerService.pickImageFromGallery();
    if (path != null) splashPath.value = path;
  }

  Future<void> pickSlideImage(int index) async {
    final path = await CreateAppPickerService.pickImageFromGallery();
    if (path == null) return;
    slides[index].imagePath = path;
    slides.refresh();
  }

  void toggleBottomNav(bool value) => bottomNavEnabled.value = value;

  void setTabMode(String id, NavTabMode mode) {
    final tab = navTabs.firstWhere((t) => t.id == id);
    tab.mode = mode;
    navTabs.refresh();
  }

  void removeTab(String id) {
    navTabs.removeWhere((t) => t.id == id);
  }

  void addTab(NavTabType type) {
    if (navTabs.any((t) => t.type == type)) return;
    navTabs.add(NavTabModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: type,
      label: L10n.navTabLabel(type),
    ));
  }

  void togglePermission(String key, bool value) {
    permissions[key] = value;
    permissions.refresh();
  }

  void toggleExtraFeature(String key, bool value) {
    extraFeatures[key] = value;
    extraFeatures.refresh();
  }

  void tryAddSlide() {
    if (canAddSlide) {
      addSlide();
      return;
    }

    AppToast.info(
      'complete_current_slide_to_add'.tr,
      description: CreateAppValidator.incompleteSlideHint(slides.last),
    );
  }

  void addSlide() {
    if (!canAddSlide) return;
    slides.add(OnboardingSlideModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
    ));
    currentSlideIndex.value = slides.length - 1;
  }

  void removeSlideImage(int index) {
    slides[index].imagePath = null;
    slides.refresh();
  }

  void prevSlide() {
    if (currentSlideIndex.value > 0) {
      currentSlideIndex.value--;
    }
  }

  void nextSlide() {
    if (currentSlideIndex.value < slides.length - 1) {
      currentSlideIndex.value++;
    }
  }

  void goToStep(int step) {
    pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void resetForNewApp() {
    currentStep.value = 0;
    fieldErrors.clear();

    websiteUrlController.clear();
    appNameController.clear();
    packageNameController.clear();
    versionCodeController.text = '1';
    versionNameController.text = '1.0.0';

    iconPath.value = null;
    splashPath.value = null;

    bottomNavEnabled.value = true;
    navTabs.assignAll(CreateAppDefaults.defaultNavTabs());

    pullToRefresh.value = false;
    desktopMode.value = false;
    keepScreenAlive.value = false;

    onboardingEnabled.value = true;
    slides.assignAll(CreateAppDefaults.defaultSlides());
    currentSlideIndex.value = 0;

    permissions.assignAll(
      Map<String, bool>.from(CreateAppDefaults.defaultPermissions),
    );
    extraFeatures.assignAll(
      Map<String, bool>.from(CreateAppDefaults.defaultExtraFeatures),
    );

    selectedThemeColor.value = CreateAppDefaults.themeColors.first;
    darkStatusBar.value = false;
    previewMode.value = PreviewMode.splash;

    appId.value = null;
    appVersionId.value = null;
    configVersion.value = null;
    isSaving.value = false;

    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
  }

  void prepareForExistingApp({
    required String appId,
    required String appVersionId,
    required int configVersion,
    required String name,
    required String androidPackage,
    required String startUrl,
    required String versionName,
    required int versionCode,
  }) {
    this.appId.value = appId;
    this.appVersionId.value = appVersionId;
    this.configVersion.value = configVersion;
    appNameController.text = name;
    packageNameController.text = androidPackage;
    websiteUrlController.text = startUrl;
    versionNameController.text = versionName;
    versionCodeController.text = versionCode.toString();
  }

  @override
  void onClose() {
    pageController.dispose();
    websiteUrlController.dispose();
    appNameController.dispose();
    packageNameController.dispose();
    versionCodeController.dispose();
    versionNameController.dispose();
    super.onClose();
  }
}
