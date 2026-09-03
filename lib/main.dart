import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_to_app/app/routes/app_pages.dart';
import 'package:web_to_app/core/ads/app_open_ad_manager.dart';
import 'package:web_to_app/core/bindings/initial_binding.dart';
import 'package:web_to_app/core/constants/app_info.dart';
import 'package:web_to_app/core/localization/app_locale.dart';
import 'package:web_to_app/core/localization/app_translations.dart';
import 'package:web_to_app/core/services/analytics_service.dart';
import 'package:web_to_app/core/services/firebase_service.dart';
import 'package:web_to_app/core/services/language_service.dart';
import 'package:web_to_app/core/theme/app_theme.dart';
import 'package:web_to_app/modules/language/data/language_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bundle fonts under assets/google_fonts/ and never fetch at runtime.
  // Prevents Crashlytics fatals when fonts.gstatic.com DNS/network fails.
  GoogleFonts.config.allowRuntimeFetching = false;

  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('assets/google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });

  await FirebaseService.init();
  await InitialBinding.init();

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const WebToApp());
}

class WebToApp extends StatefulWidget {
  const WebToApp({super.key});

  @override
  State<WebToApp> createState() => _WebToAppState();
}

class _WebToAppState extends State<WebToApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    AppOpenAdManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        unawaited(AppOpenAdManager.instance.resume());
      case AppLifecycleState.paused:
        // Only [paused] means a real background (Home / app switch).
        // [inactive]/[hidden] also fire on resume and must NOT reset the timer.
        AppOpenAdManager.instance.pause();
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
      case AppLifecycleState.detached:
        AppOpenAdManager.instance.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageId = Get.isRegistered<LanguageService>()
        ? Get.find<LanguageService>().selectedLanguageId.value
        : LanguageData.defaultLanguageId;

    return GetMaterialApp(
      title: AppInfo.name,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      translations: AppTranslations(),
      locale: AppLocale.toFlutterLocale(languageId),
      fallbackLocale: AppLocale.fallbackLocale,
      supportedLocales: AppLocale.supportedLocales,
      localizationsDelegates: AppLocale.localizationDelegates,
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
      navigatorObservers: [
        AnalyticsService.instance.navigatorObserver,
      ],
    );
  }
}
