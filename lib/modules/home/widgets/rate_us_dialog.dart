import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

Future<int?> showRateUsDialog(BuildContext context, {int initial = 0}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withValues(alpha: 0.38),
    builder: (_) => _RateUsDialog(initial: initial),
  );
}

class _RateUsDialog extends StatefulWidget {
  const _RateUsDialog({required this.initial});

  final int initial;

  @override
  State<_RateUsDialog> createState() => _RateUsDialogState();
}

class _RateUsDialogState extends State<_RateUsDialog> {
  late int _rating;
  late int _displayRating;
  late bool _hasUserRated;
  bool _isAnimating = false;
  int _bounceStar = 0;

  String get _primaryLabel =>
      _rating <= 3 ? 'rate_dialog_feedback'.tr : 'rate_dialog_rate_now'.tr;

  static const Map<String, List<String>> _ratingStatusesByLanguage = {
    'en': ['Bad', 'Poor', 'Good', 'Very Good', 'Excellent'],
    'de': ['Schlecht', 'Schwach', 'Gut', 'Sehr gut', 'Ausgezeichnet'],
    'es': ['Malo', 'Regular', 'Bueno', 'Muy bueno', 'Excelente'],
    'fr': ['Mauvais', 'Faible', 'Bon', 'Tres bien', 'Excellent'],
    'it': ['Scarso', 'Discreto', 'Buono', 'Molto buono', 'Eccellente'],
    'nl': ['Slecht', 'Matig', 'Goed', 'Zeer goed', 'Uitstekend'],
    'pl': ['Slabo', 'Przecietnie', 'Dobrze', 'Bardzo dobrze', 'Doskonale'],
    'pt': ['Ruim', 'Fraco', 'Bom', 'Muito bom', 'Excelente'],
    'ru': ['Плохо', 'Слабо', 'Хорошо', 'Очень хорошо', 'Отлично'],
    'sv': ['Daligt', 'Svagt', 'Bra', 'Mycket bra', 'Utmarkt'],
    'uk': ['Погано', 'Слабко', 'Добре', 'Дуже добре', 'Відмінно'],
    'ja': ['悪い', 'いまいち', '良い', 'とても良い', '最高'],
    'ko': ['별로예요', '아쉬워요', '좋아요', '아주 좋아요', '최고예요'],
    'zh': ['差', '一般', '好', '很好', '优秀'],
    'th': ['แย่', 'พอใช้', 'ดี', 'ดีมาก', 'ยอดเยี่ยม'],
    'vi': ['Te', 'Tam on', 'Tot', 'Rat tot', 'Xuat sac'],
    'id': ['Buruk', 'Kurang', 'Bagus', 'Sangat bagus', 'Luar biasa'],
    'ms': ['Lemah', 'Kurang', 'Bagus', 'Sangat bagus', 'Cemerlang'],
    'fil': ['Hindi maganda', 'Pwede na', 'Maganda', 'Napakaganda', 'Napakahusay'],
  };

  String get _ratingStatus {
    if (_rating <= 0) return 'rate_dialog_subtitle'.tr;
    final languageCode = Get.locale?.languageCode.toLowerCase() ?? 'en';
    final localized = _ratingStatusesByLanguage[languageCode] ??
        _ratingStatusesByLanguage['en']!;
    final index = _rating.clamp(1, 5) - 1;
    return localized[index];
  }

  @override
  void initState() {
    super.initState();
    _rating = widget.initial.clamp(0, 5);
    _displayRating = _rating;
    _hasUserRated = _rating > 0;
  }

  Future<void> _onStarTap(int value) async {
    if (_isAnimating) return;

    if (_hasUserRated) {
      setState(() {
        _rating = value;
        _displayRating = value;
      });
      return;
    }

    _isAnimating = true;
    setState(() => _displayRating = 0);

    for (var star = 1; star <= value; star++) {
      if (!mounted) return;
      setState(() {
        _displayRating = star;
        _bounceStar = star;
      });
      await Future<void>.delayed(const Duration(milliseconds: 120));
    }

    if (!mounted) return;
    setState(() {
      _rating = value;
      _hasUserRated = true;
      _isAnimating = false;
      _bounceStar = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final starSize = Responsive.w(context, 50);

    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(Responsive.w(context, 28)),
        child: DecoratedBox(
          decoration: const BoxDecoration(color: Colors.white),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 18),
                  Responsive.w(context, 22),
                  Responsive.w(context, 18),
                  Responsive.w(context, 18),
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.homeCardGradientStart,
                      AppColors.homeCardGradientMid,
                      AppColors.homeCardGradientEnd,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: Responsive.w(context, 54),
                      height: Responsive.w(context, 54),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: Responsive.w(context, 27),
                      ),
                    ),
                    SizedBox(height: Responsive.w(context, 12)),
                    Text(
                      'rate_dialog_title'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.settingsHeaderTitle(
                        context,
                      ).copyWith(color: Colors.white),
                    ),
                    SizedBox(height: Responsive.w(context, 6)),
                    Text(
                      'rate_dialog_subtitle'.tr,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.createRowSubtitle(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  Responsive.w(context, 18),
                  Responsive.w(context, 20),
                  Responsive.w(context, 18),
                  Responsive.w(context, 14),
                ),
                child: Column(
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final value = index + 1;
                          final active = value <= _displayRating;
                          final isBouncing = value == _bounceStar;
                          return IconButton(
                            onPressed: _isAnimating
                                ? null
                                : () => _onStarTap(value),
                            padding: EdgeInsets.zero,
                            constraints: BoxConstraints.tightFor(
                              width: starSize + Responsive.w(context, 12),
                              height: starSize + Responsive.w(context, 12),
                            ),
                            icon: AnimatedScale(
                              scale: isBouncing ? 1.18 : 1.0,
                              duration: const Duration(milliseconds: 120),
                              curve: Curves.easeOutBack,
                              child: Icon(
                                active
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                color: active
                                    ? const Color(0xFFFFB020)
                                    : AppColors.createFieldBorder,
                                size: starSize,
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 8)),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Text(
                        _ratingStatus,
                        key: ValueKey(_rating),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.settingsHeaderTitle(context)
                            .copyWith(
                          fontSize: Responsive.sp(context, 18),
                          color: _rating > 0
                              ? AppColors.homeTitle
                              : AppColors.createFieldBorder,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    SizedBox(
                      width: double.infinity,
                      height: Responsive.w(context, 50),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _rating > 0
                                ? const [
                                    AppColors.homeCardGradientStart,
                                    AppColors.homeCardGradientMid,
                                    AppColors.homeCardGradientEnd,
                                  ]
                                : [
                                    AppColors.createFieldBorder,
                                    AppColors.createFieldBorder,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(999),
                          boxShadow: _rating > 0
                              ? [
                                  BoxShadow(
                                    color: AppColors.homeAccent.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: Responsive.w(context, 14),
                                    offset: Offset(0, Responsive.w(context, 6)),
                                  ),
                                ]
                              : null,
                        ),
                        child: ElevatedButton(
                          onPressed: _rating > 0
                              ? () => Navigator.of(context).pop(_rating)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            disabledBackgroundColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: Text(
                            _primaryLabel,
                            style: AppTextStyles.createCta(context),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.w(context, 8)),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'rate_dialog_later'.tr,
                        style: AppTextStyles.createRowSubtitle(
                          context,
                        ).copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
