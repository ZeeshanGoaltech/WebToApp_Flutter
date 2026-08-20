import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:get/get.dart';

import 'package:web_to_app/core/localization/app_translations.dart';

import 'package:web_to_app/modules/splash/widgets/splash_logo_section.dart';

import 'package:web_to_app/modules/splash/widgets/splash_progress_bar.dart';



void main() {

  tearDown(Get.reset);



  testWidgets('Splash shows localized copy', (WidgetTester tester) async {

    await tester.pumpWidget(

      GetMaterialApp(

        translations: AppTranslations(),

        locale: const Locale('en', 'US'),

        home: const Scaffold(

          body: Column(

            children: [

              SplashLogoSection(),

              SplashProgressBar(progress: 0.5),

            ],

          ),

        ),

      ),

    );



    expect(find.text('Web to App Converter'), findsOneWidget);

    expect(find.text('Turn any website into a mobile app'), findsOneWidget);

    expect(find.text('Getting things ready…'), findsOneWidget);

  });

}


