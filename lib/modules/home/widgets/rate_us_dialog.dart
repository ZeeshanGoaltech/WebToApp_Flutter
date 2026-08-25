import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

Future<int?> showRateUsDialog(BuildContext context, {int initial = 5}) {
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
  static const _minRating = 1;
  static const _maxRating = 5;
  static const _starColor = Color(0xFFFFB020);
  static const _starFillStep = Duration(milliseconds: 140);
  static const _starBounceDuration = Duration(milliseconds: 200);

  late int _rating;
  late int _targetRating;
  int _displayRating = 0;
  int _bounceStar = 0;
  bool _isAnimating = false;

  String get _primaryLabel =>
      _rating <= 3 ? 'rate_dialog_feedback'.tr : 'rate_dialog_rate_now'.tr;

  static const _ratingStatusKeys = [
    'rate_status_bad',
    'rate_status_poor',
    'rate_status_good',
    'rate_status_very_good',
    'rate_status_excellent',
  ];

  String get _ratingStatus {
    final shown = _isAnimating ? _displayRating : _rating;
    if (shown <= 0) return 'rate_dialog_subtitle'.tr;
    final index = shown.clamp(_minRating, _maxRating) - 1;
    return _ratingStatusKeys[index].tr;
  }

  int _clampRating(int value) {
    if (value < _minRating) return _minRating;
    if (value > _maxRating) return _maxRating;
    return value;
  }

  @override
  void initState() {
    super.initState();
    _targetRating =
        widget.initial <= 0 ? _maxRating : _clampRating(widget.initial);
    _rating = _targetRating;
    _displayRating = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _playOpenFillAnimation();
    });
  }

  Future<void> _playOpenFillAnimation() async {
    if (_isAnimating) return;
    setState(() {
      _isAnimating = true;
      _displayRating = 0;
      _bounceStar = 0;
    });

    await Future<void>.delayed(const Duration(milliseconds: 80));

    for (var star = 1; star <= _targetRating; star++) {
      if (!mounted) return;
      setState(() {
        _displayRating = star;
        _bounceStar = star;
      });
      await Future<void>.delayed(_starFillStep);
    }

    if (!mounted) return;
    await Future<void>.delayed(_starBounceDuration - _starFillStep);

    if (!mounted) return;
    setState(() {
      _rating = _targetRating;
      _displayRating = _targetRating;
      _isAnimating = false;
      _bounceStar = 0;
    });
  }

  void _onStarTap(int value) {
    if (_isAnimating) return;
    setState(() {
      _rating = _clampRating(value);
      _displayRating = _rating;
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
                        children: List.generate(_maxRating, (index) {
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
                              scale: isBouncing ? 1.22 : (active ? 1.0 : 0.92),
                              duration: _starBounceDuration,
                              curve: Curves.easeOutBack,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 120),
                                switchInCurve: Curves.easeOut,
                                switchOutCurve: Curves.easeIn,
                                transitionBuilder: (child, animation) {
                                  return FadeTransition(
                                    opacity: animation,
                                    child: ScaleTransition(
                                      scale: Tween<double>(
                                        begin: 0.7,
                                        end: 1.0,
                                      ).animate(animation),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Icon(
                                  active
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  key: ValueKey<bool>(active),
                                  color: active
                                      ? _starColor
                                      : AppColors.createFieldBorder,
                                  size: starSize,
                                ),
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
                        key: ValueKey(
                          _isAnimating ? _displayRating : _rating,
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.settingsHeaderTitle(context)
                            .copyWith(
                          fontSize: Responsive.sp(context, 18),
                          color: (_isAnimating
                                      ? _displayRating
                                      : _rating) >
                                  0
                              ? AppColors.homeTitle
                              : AppColors.createFieldBorder,
                        ),
                      ),
                    ),
                    SizedBox(height: Responsive.h(context, 16)),
                    SizedBox(
                      height: Responsive.w(context, 50),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: Responsive.w(context, 8),
                                ),
                                side: BorderSide(
                                  color: AppColors.createFieldBorder,
                                  width: Responsive.w(context, 1.2),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                'rate_dialog_later'.tr,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.createRowSubtitle(
                                  context,
                                ).copyWith(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                          SizedBox(width: Responsive.w(context, 10)),
                          Expanded(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: !_isAnimating
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
                                boxShadow: !_isAnimating
                                    ? [
                                        BoxShadow(
                                          color: AppColors.homeAccent
                                              .withValues(alpha: 0.22),
                                          blurRadius: Responsive.w(context, 14),
                                          offset: Offset(
                                            0,
                                            Responsive.w(context, 6),
                                          ),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: ElevatedButton(
                                onPressed: _isAnimating
                                    ? null
                                    : () =>
                                        Navigator.of(context).pop(_rating),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  disabledBackgroundColor: Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Responsive.w(context, 8),
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                                child: Text(
                                  _primaryLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: AppTextStyles.createCta(context),
                                ),
                              ),
                            ),
                          ),
                        ],
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
