import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_placements.dart';
import 'package:web_to_app/core/ads/widgets/small_native_ad_widget.dart';
import 'package:web_to_app/core/localization/l10n.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/core/widgets/rtl_flip.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/models/onboarding_slide_model.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_labeled_field.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_toggle.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_upload_zone.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';

class Step3OnboardingPage extends GetView<CreateAppController> {
  const Step3OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        Responsive.w(context, 24),
        0,
        Responsive.w(context, 24),
        Responsive.w(context, 24),
      ),
      child: Column(
        children: [
          CreateAppCard(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'enable_onboarding'.tr,
                        style: AppTextStyles.createRowTitle(context),
                      ),
                      Text(
                        'enable_onboarding_sub'.tr,
                        style: AppTextStyles.createRowSubtitle(context),
                      ),
                    ],
                  ),
                ),
                Obx(() => CreateToggle(
                      value: controller.onboardingEnabled.value,
                      onChanged: (v) => controller.onboardingEnabled.value = v,
                    )),
              ],
            ),
          ),
          SizedBox(height: Responsive.w(context, 16)),
          const _SlidePager(),
          SizedBox(height: Responsive.w(context, 16)),
          Obx(() => _SlideEditor(index: controller.currentSlideIndex.value)),
        ],
      ),
    );
  }
}

class _SlidePager extends GetView<CreateAppController> {
  const _SlidePager();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final count = controller.slides.length;
      final currentIndex = controller.currentSlideIndex.value;
      final canAdd = controller.canAddSlide;

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ...List.generate(count, (i) {
            final active = i == currentIndex;
            return GestureDetector(
              onTap: () => controller.currentSlideIndex.value = i,
              child: Container(
                margin: EdgeInsets.only(right: Responsive.w(context, 8)),
                width: active
                    ? Responsive.w(context, 23.983)
                    : Responsive.w(context, 7.994),
                height: Responsive.w(context, 7.994),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: active ? CreateToggle.accentGradient : null,
                  color: active ? null : AppColors.createFieldBorder,
                ),
              ),
            );
          }),
          Opacity(
            opacity: canAdd ? 1 : 0.35,
            child: GestureDetector(
              onTap: controller.tryAddSlide,
              child: Container(
                width: Responsive.w(context, 31.996),
                height: Responsive.w(context, 31.996),
                decoration: BoxDecoration(
                  gradient: CreateToggle.accentGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.createAccent.withValues(alpha: 0.28),
                      blurRadius: Responsive.w(context, 10),
                      offset: Offset(0, Responsive.w(context, 4)),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: Responsive.w(context, 20),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _SlideEditor extends GetView<CreateAppController> {
  const _SlideEditor({required this.index});

  final int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final slide = controller.slides[index];
      final slideCount = controller.slides.length;

      return CreateAppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (slide.imagePath != null)
              CreateImagePreview(
                imagePath: slide.imagePath!,
                height: Responsive.w(context, 159.998),
                fit: BoxFit.cover,
                onRemove: () => controller.removeSlideImage(index),
              )
            else
              CreateUploadZone(
                label: 'upload_slide_image'.tr,
                onTap: () => controller.pickSlideImage(index),
                isLoading: controller.isImagePickerBusy,
              ),
            SizedBox(height: Responsive.w(context, 16)),
            _SlideTitleField(slide: slide, index: index),
            SizedBox(height: Responsive.w(context, 16)),
            _DescriptionField(
              key: ValueKey('desc_$index'),
              slide: slide,
              onChanged: controller.notifySlideChanged,
            ),
            SizedBox(height: Responsive.w(context, 16)),
            // Monetization: immediately above the Add CTA button setting.
            const SmallNativeAdWidget(
              placementId: AdPlacements.creationScreenNative,
              includeOuterPadding: false,
            ),
            SizedBox(height: Responsive.w(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'add_cta_button'.tr,
                  style: AppTextStyles.createFieldValue(context, size: 14),
                ),
                CreateToggle(
                  value: slide.ctaEnabled,
                  onChanged: (v) {
                    slide.ctaEnabled = v;
                    controller.notifySlideChanged();
                  },
                ),
              ],
            ),
            if (slide.ctaEnabled) ...[
              SizedBox(height: Responsive.w(context, 12)),
              _CtaLabelField(slide: slide, index: index),
            ],
            SizedBox(height: Responsive.w(context, 16)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Opacity(
                  opacity: index > 0 ? 1 : 0.3,
                  child: GestureDetector(
                    onTap: index > 0 ? controller.prevSlide : null,
                    child: Row(
                      children: [
                        RtlFlip(
                          child: FigmaSvgIcon(
                            asset: CreateAppAssets.chevronPrev,
                            size: Responsive.w(context, 15.989),
                          ),
                        ),
                        Text('previous'.tr, style: AppTextStyles.createLink(context)),
                      ],
                    ),
                  ),
                ),
                Text(
                  L10n.slideOf(index + 1, slideCount),
                  style: AppTextStyles.createRowSubtitle(context),
                ),
                GestureDetector(
                  onTap: index < slideCount - 1 ? controller.nextSlide : null,
                  child: Row(
                    children: [
                      Text('cta_next'.tr, style: AppTextStyles.createLink(context)),
                      RtlFlip(
                        child: FigmaSvgIcon(
                          asset: CreateAppAssets.chevronNext,
                          size: Responsive.w(context, 15.989),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _SlideTitleField extends GetView<CreateAppController> {
  const _SlideTitleField({required this.slide, required this.index});

  final OnboardingSlideModel slide;
  final int index;

  @override
  Widget build(BuildContext context) {
    return _SlideBoundField(
      key: ValueKey('title_$index'),
      initialValue: slide.title,
      onChanged: (v) {
        slide.title = v;
        controller.notifySlideChanged();
      },
      builder: (textController, _) => Obx(() => CreateLabeledField(
            label: 'slide_title'.tr,
            controller: textController,
            hint: 'slide_title_hint'.tr,
            errorText: controller.fieldErrors['slideTitle_$index'],
          )),
    );
  }
}

class _CtaLabelField extends GetView<CreateAppController> {
  const _CtaLabelField({required this.slide, required this.index});

  final OnboardingSlideModel slide;
  final int index;

  @override
  Widget build(BuildContext context) {
    return _SlideBoundField(
      key: ValueKey('cta_$index'),
      initialValue: slide.ctaLabel,
      onChanged: (v) {
        slide.ctaLabel = v;
        controller.notifySlideChanged();
      },
      builder: (textController, _) => Obx(() => CreateLabeledField(
            label: 'button_label'.tr,
            controller: textController,
            hint: 'button_label_hint'.tr,
            errorText: controller.fieldErrors['slideCta_$index'],
          )),
    );
  }
}

class _DescriptionField extends StatefulWidget {
  const _DescriptionField({
    super.key,
    required this.slide,
    required this.onChanged,
  });

  final OnboardingSlideModel slide;
  final VoidCallback onChanged;

  @override
  State<_DescriptionField> createState() => _DescriptionFieldState();
}

class _DescriptionFieldState extends State<_DescriptionField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.slide.description);
    _controller.addListener(_handleTextChanged);
  }

  void _handleTextChanged() {
    widget.slide.description = _controller.text;
    widget.onChanged();
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CreateLabeledTextArea(
      label: 'description'.tr,
      controller: _controller,
      hint: 'description_hint'.tr,
    );
  }
}

class _SlideBoundField extends StatefulWidget {
  const _SlideBoundField({
    super.key,
    required this.initialValue,
    required this.onChanged,
    required this.builder,
  });

  final String initialValue;
  final ValueChanged<String> onChanged;
  final Widget Function(TextEditingController controller, void Function() setState)
      builder;

  @override
  State<_SlideBoundField> createState() => _SlideBoundFieldState();
}

class _SlideBoundFieldState extends State<_SlideBoundField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() => widget.onChanged(_controller.text));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_controller, () => setState(() {}));
  }
}
