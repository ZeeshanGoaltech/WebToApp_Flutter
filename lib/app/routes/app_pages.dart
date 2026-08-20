import 'package:get/get.dart';
import 'package:web_to_app/app/routes/app_routes.dart';
import 'package:web_to_app/modules/create_app/bindings/create_app_binding.dart';
import 'package:web_to_app/modules/create_app/views/build_app_view.dart';
import 'package:web_to_app/modules/create_app/views/create_app_view.dart';
import 'package:web_to_app/modules/auth/bindings/auth_binding.dart';
import 'package:web_to_app/modules/auth/views/auth_view.dart';
import 'package:web_to_app/modules/home/bindings/home_binding.dart';
import 'package:web_to_app/modules/home/views/home_view.dart';
import 'package:web_to_app/modules/intro/bindings/intro_binding.dart';
import 'package:web_to_app/modules/intro/views/intro_view.dart';
import 'package:web_to_app/modules/language/bindings/language_binding.dart';
import 'package:web_to_app/modules/language/views/language_view.dart';
import 'package:web_to_app/modules/iap/bindings/iap_binding.dart';
import 'package:web_to_app/modules/iap/bindings/lifetime_premium_binding.dart';
import 'package:web_to_app/modules/iap/views/iap_view.dart';
import 'package:web_to_app/modules/iap/views/lifetime_premium_view.dart';
import 'package:web_to_app/modules/splash/bindings/splash_binding.dart';
import 'package:web_to_app/modules/splash/views/splash_view.dart';

class AppPages {
  AppPages._();

  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.language,
      page: () => const LanguageView(),
      binding: LanguageBinding(),
    ),
    GetPage(
      name: AppRoutes.intro,
      page: () => const IntroView(),
      binding: IntroBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.createApp,
      page: () => const CreateAppView(),
      binding: CreateAppBinding(),
    ),
    GetPage(
      name: AppRoutes.buildApp,
      page: () => const BuildAppView(),
      binding: CreateAppBinding(),
    ),
    GetPage(
      name: AppRoutes.iap,
      page: () => const IapView(),
      binding: IapBinding(),
      popGesture: false,
    ),
    GetPage(
      name: AppRoutes.lifetimePremium,
      page: () => const LifetimePremiumView(),
      binding: LifetimePremiumBinding(),
      popGesture: false,
    ),
  ];
}
