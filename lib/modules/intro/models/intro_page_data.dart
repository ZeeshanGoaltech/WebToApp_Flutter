class IntroPageData {
  const IntroPageData({
    required this.heroAsset,
    required this.heroWidth,
    required this.heroHeight,
    required this.heroHorizontalPadding,
    required this.contentLeftPadding,
    required this.titleLines,
    required this.description,
    required this.heroTopSpacing,
    required this.contentTopSpacing,
    required this.nextButtonRight,
  });

  final String heroAsset;
  final double heroWidth;
  final double heroHeight;
  final double heroHorizontalPadding;
  final double contentLeftPadding;
  final List<String> titleLines;
  final String description;
  final double heroTopSpacing;
  final double contentTopSpacing;
  /// Distance from screen right edge to next button (Figma 440.705 frame).
  final double nextButtonRight;
}
