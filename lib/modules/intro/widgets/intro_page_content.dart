import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/intro/models/intro_page_data.dart';
import 'package:web_to_app/modules/intro/widgets/intro_bottom_bar.dart';

/// Intro page: image + text + buttons packed at top (no gap under image).
/// Leftover height goes below the buttons for the ad zone.
class IntroPageContent extends StatelessWidget {
  const IntroPageContent({
    super.key,
    required this.page,
    required this.pageIndex,
    required this.onNext,
  });

  final IntroPageData page;
  final int pageIndex;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final titleStyle = AppTextStyles.introTitle(context);
    final bodyStyle = AppTextStyles.introBody(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final heroTop = Responsive.h(context, page.heroTopSpacing);
        final contentGap = Responsive.h(context, page.contentTopSpacing);
        final titleDescGap = Responsive.h(context, 8);
        final bottomBarH =
            Responsive.h(context, 10) + Responsive.w(context, 63.281);

        final titleH =
            (titleStyle.fontSize ?? 29) * (titleStyle.height ?? 1.25) * 2;
        final descH =
            (bodyStyle.fontSize ?? 16) * (bodyStyle.height ?? 1.65) * 3;
        final fixed =
            heroTop + contentGap + titleH + titleDescGap + descH + bottomBarH;

        var heroH = Responsive.h(context, page.heroHeight);
        final maxHero = (constraints.maxHeight - fixed).clamp(0.0, heroH);
        // Keep hero as large as possible; only shrink if it would overflow.
        if (maxHero < heroH) heroH = maxHero;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (heroTop > 0) SizedBox(height: heroTop),
            SizedBox(
              height: heroH,
              width: double.infinity,
              child: Padding(
                padding: EdgeInsetsDirectional.only(
                  start: Responsive.w(context, page.contentLeftPadding),
                  end: Responsive.w(context, 24),
                ),
                child: Image.asset(
                  page.heroAsset,
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: double.infinity,
                  alignment: Alignment.center,
                ),
              ),
            ),
            SizedBox(height: contentGap),
            Padding(
              padding: EdgeInsetsDirectional.only(
                start: Responsive.w(context, page.contentLeftPadding),
                end: Responsive.w(context, 24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...page.titleLines.map(
                    (line) => Text(line, style: titleStyle),
                  ),
                  SizedBox(height: titleDescGap),
                  Text(page.description, style: bodyStyle),
                ],
              ),
            ),
            IntroBottomBar(
              currentPage: pageIndex,
              onNext: onNext,
            ),
            const Spacer(),
          ],
        );
      },
    );
  }
}
