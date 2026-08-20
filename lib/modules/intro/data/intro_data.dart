import 'package:get/get.dart';
import 'package:web_to_app/core/constants/app_assets.dart';
import 'package:web_to_app/modules/intro/models/intro_page_data.dart';

class IntroData {
  IntroData._();

  static const int pageCount = 3;
  static const double designWidth = 440.705;

  static List<IntroPageData> get pages => [
        IntroPageData(
          heroAsset: AppAssets.intro1,
          heroWidth: 416,
          heroHeight: 356,
          heroHorizontalPadding: 22.6,
          contentLeftPadding: 22.6,
          titleLines: ['intro1_title_line1'.tr, 'intro1_title_line2'.tr],
          description: 'intro1_desc'.tr,
          heroTopSpacing: 0,
          contentTopSpacing: 6,
          nextButtonRight: 13.564,
        ),
        IntroPageData(
          heroAsset: AppAssets.intro2,
          heroWidth: 398,
          heroHeight: 332,
          heroHorizontalPadding: 28.25,
          contentLeftPadding: 28.25,
          titleLines: ['intro2_title_line1'.tr, 'intro2_title_line2'.tr],
          description: 'intro2_desc'.tr,
          heroTopSpacing: 0,
          contentTopSpacing: 6,
          nextButtonRight: 36.164,
        ),
        IntroPageData(
          heroAsset: AppAssets.intro3,
          heroWidth: 404,
          heroHeight: 338,
          heroHorizontalPadding: 29.38,
          contentLeftPadding: 29.38,
          titleLines: ['intro3_title_line1'.tr, 'intro3_title_line2'.tr],
          description: 'intro3_desc'.tr,
          heroTopSpacing: 0,
          contentTopSpacing: 6,
          nextButtonRight: 36.155,
        ),
      ];
}
