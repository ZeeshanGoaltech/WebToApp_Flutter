import 'package:flutter/material.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/intro/data/intro_data.dart';
import 'package:web_to_app/modules/intro/widgets/intro_circle_next_button.dart';
import 'package:web_to_app/modules/intro/widgets/intro_dots.dart';
import 'package:web_to_app/modules/intro/widgets/intro_get_started_button.dart';

class IntroBottomBar extends StatelessWidget {
  const IntroBottomBar({
    super.key,
    required this.currentPage,
    required this.onNext,
  });

  final int currentPage;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final page = IntroData.pages[currentPage];
    final isLastPage = currentPage == IntroData.pageCount - 1;

    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: Responsive.w(context, 36.16),
        top: Responsive.h(context, 10),
        end: Responsive.w(context, page.nextButtonRight),
        bottom: 0,
      ),
      child: SizedBox(
        height: Responsive.w(context, 63.281),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IntroDots(currentPage: currentPage),
            const Spacer(),
            if (isLastPage)
              IntroGetStartedButton(onPressed: onNext)
            else
              IntroCircleNextButton(onPressed: onNext),
          ],
        ),
      ),
    );
  }
}
