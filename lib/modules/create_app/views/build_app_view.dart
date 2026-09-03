import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/constants/create_app_assets.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/button_loading_indicator.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';
import 'package:web_to_app/modules/create_app/controllers/build_app_controller.dart';
import 'package:web_to_app/modules/create_app/controllers/create_app_controller.dart';
import 'package:web_to_app/modules/create_app/models/preview_mode.dart';
import 'package:web_to_app/modules/create_app/widgets/fields/create_picked_image.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_card.dart';
import 'package:web_to_app/modules/create_app/widgets/shell/create_app_header.dart';

class BuildAppView extends GetView<BuildAppController> {
  const BuildAppView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.prepareForCurrentApp();
    final createController = Get.find<CreateAppController>();

    return Obx(() {
      return PopScope(
        canPop: !controller.shouldConfirmBuildExit,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          await _handleBack(context);
        },
        child: Scaffold(
          backgroundColor: AppColors.createBackground,
          body: SafeArea(
            child: Column(
              children: [
                CreateBuildHeader(onBack: () => _handleBack(context)),
                Expanded(
                  child: _BuildAppBody(createController: createController),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Future<void> _handleBack(BuildContext context) async {
    if (AdPresentationGate.shouldBlockBack) return;

    if (!controller.shouldConfirmBuildExit) {
      if (controller.shouldNavigateHomeOnBack) {
        controller.backToHome();
      } else {
        Get.back();
      }
      return;
    }

    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _BuildExitDialog(),
    );
    if (shouldExit != true) return;

    await controller.cancelBuildForExit();
    if (!context.mounted) return;

    await Future<void>.delayed(Duration.zero);
    if (controller.shouldNavigateHomeOnBack) {
      controller.backToHome();
    } else {
      Get.back();
    }
  }
}

class _BuildExitDialog extends StatelessWidget {
  const _BuildExitDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: Responsive.w(context, 24)),
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(Responsive.w(context, 22)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(Responsive.w(context, 28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: Responsive.w(context, 32),
              offset: Offset(0, Responsive.w(context, 16)),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: Responsive.w(context, 64),
              height: Responsive.w(context, 64),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFB84D), Color(0xFFFF7A59)],
                ),
                borderRadius: BorderRadius.circular(Responsive.w(context, 22)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF7A59).withValues(alpha: 0.28),
                    blurRadius: Responsive.w(context, 18),
                    offset: Offset(0, Responsive.w(context, 8)),
                  ),
                ],
              ),
              child: Icon(
                Icons.hourglass_top_rounded,
                color: Colors.white,
                size: Responsive.w(context, 32),
              ),
            ),
            SizedBox(height: Responsive.w(context, 18)),
            Text(
              'build_exit_title'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.createHeaderTitle(
                context,
              ).copyWith(fontSize: Responsive.sp(context, 21)),
            ),
            SizedBox(height: Responsive.w(context, 10)),
            Text(
              'build_exit_message'.tr,
              textAlign: TextAlign.center,
              style: AppTextStyles.createRowSubtitle(
                context,
              ).copyWith(height: 1.45),
            ),
            SizedBox(height: Responsive.w(context, 22)),
            Row(
              children: [
                Expanded(
                  child: _BuildExitDialogButton(
                    label: 'build_exit_stay'.tr,
                    background: AppColors.createFieldBg,
                    foreground: AppColors.createMuted,
                    onTap: () => Navigator.of(context).pop(false),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: _BuildExitDialogButton(
                    label: 'build_exit_confirm'.tr,
                    background: AppColors.primary,
                    foreground: Colors.white,
                    onTap: () => Navigator.of(context).pop(true),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildExitDialogButton extends StatelessWidget {
  const _BuildExitDialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: Responsive.w(context, 14)),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.createFieldValue(
              context,
              size: 14,
            ).copyWith(color: foreground, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}

class _BuildAppBody extends GetView<BuildAppController> {
  const _BuildAppBody({required this.createController});

  final CreateAppController createController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.buildState.value;
      final hPad = Responsive.w(context, 24);

      return Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                Responsive.h(context, 20),
                hPad,
                Responsive.h(context, 28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SummaryCard(createController: createController),
                  if (controller.isPostBuild) ...[
                    SizedBox(height: Responsive.h(context, 20)),
                    const _SuccessBanner(),
                  ],
                  SizedBox(height: Responsive.h(context, 28)),
                  Text(
                    'build_format'.tr,
                    style: AppTextStyles.createSectionTitle(context),
                  ),
                  SizedBox(height: Responsive.h(context, 14)),
                  Row(
                    children: [
                      Expanded(
                        child: _FormatCard(
                          icon: CreateAppAssets.apk,
                          title: 'apk_file'.tr,
                          subtitle: 'apk_file_sub'.tr,
                          selected: controller.selectedFormats.contains(
                            BuildFormat.apk,
                          ),
                          onTap: () =>
                              controller.toggleFormat(BuildFormat.apk),
                        ),
                      ),
                      SizedBox(width: Responsive.w(context, 12)),
                      Expanded(
                        child: _FormatCard(
                          icon: CreateAppAssets.aab,
                          title: 'aab_bundle'.tr,
                          subtitle: 'aab_bundle_sub'.tr,
                          selected: controller.selectedFormats.contains(
                            BuildFormat.aab,
                          ),
                          onTap: () =>
                              controller.toggleFormat(BuildFormat.aab),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: Responsive.h(context, 16)),
                  _KeystoreSection(),
                  if (state == BuildState.building ||
                      state == BuildState.failed) ...[
                    SizedBox(height: Responsive.h(context, 24)),
                    const _BuildProgressCard(),
                  ],
                  if (controller.showApkCard) ...[
                    SizedBox(height: Responsive.h(context, 24)),
                    _ArtifactFileCards(createController: createController),
                  ],
                  if (controller.isPostBuild) ...[
                    SizedBox(height: Responsive.h(context, 28)),
                    const _ArtifactActionsPanel(),
                  ],
                  if (!controller.isPostBuild) ...[
                    SizedBox(height: Responsive.h(context, 28)),
                    _PrimaryActionButton(createController: createController),
                  ],
                ],
              ),
            ),
          ),
          // Fixed bottom bar — Build Again / Go to Home never scroll.
          if (controller.isPostBuild)
            Container(
              padding: EdgeInsets.fromLTRB(
                hPad,
                Responsive.h(context, 14),
                hPad,
                Responsive.h(context, 16),
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: AppColors.createFieldBorder,
                    width: 1.16,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OutlineActionButton(
                    label: 'build_again'.tr,
                    icon: CreateAppAssets.hammerMuted,
                    labelColor: AppColors.createMuted,
                    onTap: controller.onBuildAgainTapped,
                  ),
                  SizedBox(height: Responsive.h(context, 12)),
                  _GradientActionButton(
                    label: 'go_to_home'.tr,
                    onTap: controller.onGoToHomeTapped,
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.createController});

  final CreateAppController createController;

  @override
  Widget build(BuildContext context) {
    final name = createController.appNameController.text.trim();
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';

    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 17.16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Responsive.w(context, 20)),
        gradient: LinearGradient(
          colors: [
            AppColors.createAccent.withValues(alpha: 0.1),
            AppColors.createAccent.withValues(alpha: 0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.createCardShadow,
            blurRadius: Responsive.w(context, 8),
            offset: Offset(0, Responsive.w(context, 2)),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            child: SizedBox(
              width: Responsive.w(context, 47.985),
              height: Responsive.w(context, 47.985),
              child: createController.iconPath.value != null
                  ? CreatePickedImage(
                      imagePath: createController.iconPath.value!,
                      fit: BoxFit.cover,
                    )
                  : DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppTextStyles.createHeaderTitle(
                            context,
                          ).copyWith(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(width: Responsive.w(context, 12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isEmpty ? 'your_app'.tr : name,
                  style: AppTextStyles.createSectionTitle(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  createController.packageNameController.text.trim().isEmpty
                      ? 'com.myapp.awesome'
                      : createController.packageNameController.text.trim(),
                  style: AppTextStyles.createPackageField(
                    context,
                  ).copyWith(color: AppColors.createMuted, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  createController.versionNameController.text.trim().isEmpty
                      ? 'v1.0.0'
                      : 'v${createController.versionNameController.text.trim()}',
                  style: AppTextStyles.createRowSubtitle(context),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: Get.find<BuildAppController>().editApp,
            child: FigmaSvgIcon(
              asset: CreateAppAssets.edit,
              size: Responsive.w(context, 19.995),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  const _SuccessBanner();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: Responsive.w(context, 20),
              height: Responsive.w(context, 20),
              decoration: const BoxDecoration(
                color: AppColors.createSuccess,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: FigmaSvgIcon(
                  asset: CreateAppAssets.buildSuccessCheck,
                  size: Responsive.w(context, 16),
                ),
              ),
            ),
            SizedBox(width: Responsive.w(context, 8)),
            Text(
              'build_successful'.tr,
              style: AppTextStyles.createSectionTitle(context).copyWith(
                color: const Color(0xFF00A03D),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        SizedBox(height: Responsive.w(context, 4)),
        Text(
          'app_ready_download'.tr,
          style: AppTextStyles.createRowSubtitle(
            context,
          ).copyWith(color: const Color(0xFF16A34A)),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _FormatCard extends StatelessWidget {
  const _FormatCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 12),
            vertical: Responsive.w(context, 14),
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(context, 16)),
            border: Border.all(
              color: selected
                  ? AppColors.createAccent
                  : AppColors.createFieldBorder,
              width: 1.16,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: Responsive.w(context, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FigmaSvgIcon(asset: icon, size: Responsive.w(context, 28)),
                    SizedBox(height: Responsive.w(context, 8)),
                    Text(
                      title,
                      style: AppTextStyles.createRowTitle(context),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.w(context, 2)),
                    Text(
                      subtitle,
                      style: AppTextStyles.createRowSubtitle(context).copyWith(
                        fontSize: Responsive.sp(context, 11),
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: Responsive.w(context, 19.995),
                    height: Responsive.w(context, 19.995),
                    decoration: const BoxDecoration(
                      color: AppColors.createAccent,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: FigmaSvgIcon(
                        asset: CreateAppAssets.check,
                        size: Responsive.w(context, 11.983),
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeystoreSection extends GetView<BuildAppController> {
  @override
  Widget build(BuildContext context) {
    return CreateAppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'app_signing'.tr,
            style: AppTextStyles.createFieldValue(context, size: 14),
          ),
          SizedBox(height: Responsive.w(context, 4)),
          Text(
            'signing_required'.tr,
            style: AppTextStyles.createRowSubtitle(
              context,
            ).copyWith(fontSize: Responsive.sp(context, 11)),
          ),
          SizedBox(height: Responsive.w(context, 16)),
          Obx(() {
            final mode = controller.signingMode.value;
            return Row(
              children: [
                Expanded(
                  child: _SigningModeChip(
                    label: 'auto_generate'.tr,
                    subtitle: 'auto_generate_sub'.tr,
                    selected: mode == SigningMode.auto,
                    onTap: () => controller.selectSigningMode(SigningMode.auto),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: _SigningModeChip(
                    label: 'upload_keystore'.tr,
                    subtitle: 'upload_keystore_sub'.tr,
                    selected: mode == SigningMode.upload,
                    onTap: () =>
                        controller.selectSigningMode(SigningMode.upload),
                  ),
                ),
              ],
            );
          }),
          Obx(() {
            if (controller.signingMode.value != SigningMode.upload) {
              return const SizedBox.shrink();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: Responsive.w(context, 16)),
                Text(
                  'keystore_file'.tr,
                  style: AppTextStyles.createFieldLabel(context),
                ),
                SizedBox(height: Responsive.w(context, 8)),
                Obx(() {
                  final name = controller.keystoreFileName.value;
                  final picking = controller.isPickingKeystore.value;

                  if (name != null) {
                    return Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: Responsive.w(context, 16),
                        vertical: Responsive.w(context, 14),
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.createAccent,
                          width: 1.16,
                        ),
                        borderRadius: BorderRadius.circular(
                          Responsive.w(context, 999),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: AppTextStyles.createFieldValue(
                                context,
                                size: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          GestureDetector(
                            onTap: controller.clearKeystore,
                            child: Text(
                              '✕',
                              style: TextStyle(
                                color: AppColors.createDelete,
                                fontWeight: FontWeight.bold,
                                fontSize: Responsive.sp(context, 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: picking ? null : controller.pickKeystore,
                      borderRadius: BorderRadius.circular(
                        Responsive.w(context, 999),
                      ),
                      child: Ink(
                        height: Responsive.w(context, 47.278),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                            Responsive.w(context, 999),
                          ),
                          border: Border.all(
                            color: AppColors.createAccent,
                            width: 1.16,
                          ),
                        ),
                        child: Center(
                          child: picking
                              ? SizedBox(
                                  width: Responsive.w(context, 20),
                                  height: Responsive.w(context, 20),
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    FigmaSvgIcon(
                                      asset: CreateAppAssets.upload,
                                      size: Responsive.w(context, 15.989),
                                    ),
                                    SizedBox(width: Responsive.w(context, 8)),
                                    Text(
                                      'choose_file'.tr,
                                      style: AppTextStyles.createFieldValue(
                                        context,
                                        size: 14,
                                      ).copyWith(color: AppColors.createAccent),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                }),
                SizedBox(height: Responsive.w(context, 16)),
                _SigningField(
                  label: 'keystore_password'.tr,
                  controller: controller.keystoreStorePasswordController,
                  obscure: true,
                ),
                SizedBox(height: Responsive.w(context, 12)),
                _SigningField(
                  label: 'key_alias'.tr,
                  controller: controller.keystoreKeyAliasController,
                ),
                SizedBox(height: Responsive.w(context, 12)),
                _SigningField(
                  label: 'key_password'.tr,
                  controller: controller.keystoreKeyPasswordController,
                  obscure: true,
                ),
              ],
            );
          }),
          SizedBox(height: Responsive.w(context, 16)),
          Text(
            'build_number'.tr,
            style: AppTextStyles.createFieldLabel(context),
          ),
          SizedBox(height: Responsive.w(context, 8)),
          TextField(
            controller: controller.buildNumberController,
            keyboardType: TextInputType.number,
            style: AppTextStyles.createFieldValue(context, size: 14),
            decoration: InputDecoration(
              hintText: '1',
              hintStyle: AppTextStyles.createFieldHint(context),
              filled: true,
              fillColor: AppColors.createFieldBg,
              contentPadding: EdgeInsets.symmetric(
                horizontal: Responsive.w(context, 17.16),
                vertical: Responsive.w(context, 12),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                borderSide: const BorderSide(
                  color: AppColors.createFieldBorder,
                  width: 1.16,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
                borderSide: const BorderSide(
                  color: AppColors.createFieldFocus,
                  width: 1.16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BuildProgressCard extends GetView<BuildAppController> {
  const _BuildProgressCard();

  @override
  Widget build(BuildContext context) {
    return CreateAppCard(
      padding: EdgeInsets.all(Responsive.w(context, 24)),
      child: Obx(() {
        final progress = controller.buildProgress.value;
        final percent = (progress * 100).round();
        final failed = controller.buildState.value == BuildState.failed;
        final accent =
            failed ? AppColors.createDelete : AppColors.createAccent;

        return Column(
          children: [
            SizedBox(
              width: Responsive.w(context, 47.985),
              height: Responsive.w(context, 47.985),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.rotate(
                    angle: -math.pi / 2,
                    child: CircularProgressIndicator(
                      value: failed ? 1 : progress,
                      strokeWidth: Responsive.w(context, 4),
                      backgroundColor: AppColors.createFieldBorder,
                      color: accent,
                    ),
                  ),
                  Text(
                    failed ? '!' : '$percent%',
                    style: AppTextStyles.createFieldValue(context, size: 13)
                        .copyWith(
                          color: accent,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Responsive.w(context, 8)),
            Text(
              controller.buildStatusMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.createRowSubtitle(
                context,
              ).copyWith(
                fontSize: Responsive.sp(context, 13),
                color: failed ? AppColors.createDelete : null,
              ),
            ),
            GestureDetector(
              onTap: controller.toggleLogExpanded,
              child: Padding(
                padding: EdgeInsets.only(top: Responsive.w(context, 16)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'view_build_log'.tr,
                      style: AppTextStyles.createFieldValue(
                        context,
                        size: 13,
                      ).copyWith(color: AppColors.createAccent),
                    ),
                    SizedBox(width: Responsive.w(context, 4)),
                    Icon(
                      controller.logExpanded.value
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: Responsive.w(context, 16),
                      color: AppColors.createAccent,
                    ),
                  ],
                ),
              ),
            ),
            if (controller.logExpanded.value) ...[
              SizedBox(height: Responsive.w(context, 12)),
              Container(
                width: double.infinity,
                height: Responsive.w(context, 180),
                padding: EdgeInsets.all(Responsive.w(context, 12)),
                decoration: BoxDecoration(
                  color: AppColors.createLogBg,
                  borderRadius: BorderRadius.circular(
                    Responsive.w(context, 14),
                  ),
                ),
                child: ListView(
                  children: controller.buildLogs
                      .map(
                        (log) => Text(
                          log,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: Responsive.sp(context, 10),
                            height: 1.5,
                            color: log.startsWith('✓')
                                ? const Color(0xFF8B84FF)
                                : const Color(0xFF22C55E),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ],
        );
      }),
    );
  }
}

class _ArtifactFileCards extends GetView<BuildAppController> {
  const _ArtifactFileCards({required this.createController});

  final CreateAppController createController;

  String _artifactName(BuildFormat format) {
    final name = createController.appNameController.text.trim();
    final slug = name.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return '${slug.isEmpty ? 'MyAwesomeApp' : slug}.${controller.artifactType(format)}';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final formats = controller.selectedBuildFormats;

      return Column(
        children: List.generate(formats.length, (index) {
          final format = formats[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == formats.length - 1
                  ? 0
                  : Responsive.w(context, 10),
            ),
            child: _ArtifactFileCard(
              title: _artifactName(format),
              icon: format == BuildFormat.apk
                  ? CreateAppAssets.apk
                  : CreateAppAssets.aab,
              subtitle: _artifactSubtitle(context, format),
            ),
          );
        }),
      );
    });
  }

  String _artifactSubtitle(BuildContext context, BuildFormat format) {
    final downloading =
        controller.buildState.value == BuildState.downloading &&
        controller.downloadingFormat.value == format;
    if (!downloading) return controller.apkSizeLabel.value;

    final pct = (controller.downloadProgress.value * 100).round();
    return '${controller.apkSizeLabel.value} · $pct%';
  }
}

class _ArtifactFileCard extends StatelessWidget {
  const _ArtifactFileCard({
    required this.title,
    required this.icon,
    required this.subtitle,
  });

  final String title;
  final String icon;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(Responsive.w(context, 16)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Responsive.w(context, 18)),
        border: Border.all(color: const Color(0xFFEBEBF0), width: 1.16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: Responsive.w(context, 12),
            offset: Offset(0, Responsive.w(context, 2)),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: Responsive.w(context, 43.997),
            height: Responsive.w(context, 43.997),
            decoration: BoxDecoration(
              color: AppColors.createAccentLight,
              borderRadius: BorderRadius.circular(Responsive.w(context, 12)),
            ),
            child: Center(
              child: FigmaSvgIcon(
                asset: icon,
                size: Responsive.w(context, 19.995),
              ),
            ),
          ),
          SizedBox(width: Responsive.w(context, 16)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.createFieldValue(
                    context,
                    size: 13,
                  ).copyWith(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTextStyles.createRowSubtitle(context).copyWith(
                    fontSize: Responsive.sp(context, 11),
                    color: const Color(0xFF9999AA),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryActionButton extends GetView<BuildAppController> {
  const _PrimaryActionButton({required this.createController});

  final CreateAppController createController;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.buildState.value;
      final isEnqueueing = controller.isEnqueueing.value;
      final isFetchingDownload = controller.isFetchingDownload.value;

      if (state == BuildState.building && !isEnqueueing) {
        return const SizedBox.shrink();
      }

      late final String label;
      late final Widget? leading;
      late final VoidCallback? onTap;
      var isLoading = false;

      switch (state) {
        case BuildState.ready:
        case BuildState.failed:
          label = isEnqueueing ? 'starting_build'.tr : 'generate_apk_aab'.tr;
          leading = isEnqueueing
              ? const ButtonLoadingIndicator()
              : FigmaSvgIcon(
                  asset: CreateAppAssets.hammer,
                  size: Responsive.w(context, 19.995),
                  color: Colors.white,
                );
          onTap = isEnqueueing ? null : controller.startBuild;
          isLoading = isEnqueueing;
        case BuildState.success:
          label = isFetchingDownload
              ? 'preparing_download'.tr
              : 'download_apk'.tr;
          leading = isFetchingDownload
              ? const ButtonLoadingIndicator()
              : FigmaSvgIcon(
                  asset: CreateAppAssets.download,
                  size: Responsive.w(context, 20),
                  color: Colors.white,
                );
          onTap = isFetchingDownload ? null : controller.downloadApk;
          isLoading = isFetchingDownload;
        case BuildState.downloading:
          label = 'downloading_apk'.tr;
          leading = SizedBox(
            width: Responsive.w(context, 32),
            height: Responsive.w(context, 32),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          );
          onTap = null;
        case BuildState.downloaded:
          label = 'apk_downloaded'.tr;
          leading = Container(
            width: Responsive.w(context, 32),
            height: Responsive.w(context, 32),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: FigmaSvgIcon(
                asset: CreateAppAssets.check,
                size: Responsive.w(context, 16),
                color: Colors.white,
              ),
            ),
          );
          onTap = null;
        case BuildState.building:
          return const SizedBox.shrink();
      }

      final showSizeSuffix = state != BuildState.ready;

      return _GradientActionButton(
        label: label,
        sizeSuffix: showSizeSuffix ? controller.apkSizeLabel.value : null,
        leading: leading,
        onTap: onTap,
        isLoading: isLoading,
      );
    });
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    this.sizeSuffix,
    this.leading,
    this.onTap,
    this.isLoading = false,
  });

  final String label;
  final String? sizeSuffix;
  final Widget? leading;
  final VoidCallback? onTap;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 56);
    final radius = Responsive.w(context, 18);

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: AppColors.createAccent.withValues(alpha: 0.35),
            blurRadius: Responsive.w(context, 12),
            offset: Offset(0, Responsive.w(context, 8)),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                transform: GradientRotation(171.86 * math.pi / 180),
                colors: [Color(0xFF6C63FF), Color(0xFF8B84FF)],
              ),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading!,
                    SizedBox(width: Responsive.w(context, 12)),
                  ],
                  Text(
                    label,
                    style: AppTextStyles.createCta(context).copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: Responsive.sp(context, 15),
                    ),
                  ),
                  if (sizeSuffix != null) ...[
                    SizedBox(width: Responsive.w(context, 8)),
                    Text(
                      '· $sizeSuffix',
                      style: AppTextStyles.createCta(context).copyWith(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: Responsive.sp(context, 13),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ArtifactActionsPanel extends GetView<BuildAppController> {
  const _ArtifactActionsPanel();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final formats = controller.selectedBuildFormats;
      return Column(
        children: List.generate(formats.length, (index) {
          final format = formats[index];
          final label = controller.artifactLabel(format);
          final downloading = controller.downloadingFormat.value == format;
          final sharing = controller.sharingFormat.value == format;
          return Padding(
            padding: EdgeInsets.only(
              bottom: index == formats.length - 1
                  ? 0
                  : Responsive.w(context, 10),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _OutlineActionButton(
                    label: downloading
                        ? 'preparing_download'.tr
                        : '${'download'.tr} $label',
                    icon: CreateAppAssets.download,
                    labelColor: AppColors.createAccent,
                    onTap: controller.isFetchingDownload.value
                        ? null
                        : () => controller.downloadArtifact(format),
                  ),
                ),
                SizedBox(width: Responsive.w(context, 12)),
                Expanded(
                  child: _OutlineActionButton(
                    label: sharing
                        ? 'preparing_download'.tr
                        : '${'share_app_btn'.tr} $label',
                    icon: CreateAppAssets.share,
                    labelColor: AppColors.createAccent,
                    onTap: controller.isSharingApp.value
                        ? null
                        : () => controller.shareArtifact(format),
                  ),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({
    required this.label,
    required this.icon,
    required this.labelColor,
    required this.onTap,
  });

  final String label;
  final String icon;
  final Color labelColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Ink(
          height: Responsive.w(context, 48),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(color: const Color(0xFFEBEBF0), width: 1.208),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: Responsive.w(context, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FigmaSvgIcon(
                asset: icon,
                size: Responsive.w(context, 16),
                color: onTap == null
                    ? labelColor.withValues(alpha: 0.45)
                    : null,
              ),
              SizedBox(width: Responsive.w(context, 8)),
              Text(
                label,
                style: AppTextStyles.createFieldValue(context, size: 13)
                    .copyWith(
                      color: onTap == null
                          ? labelColor.withValues(alpha: 0.45)
                          : labelColor,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SigningModeChip extends StatelessWidget {
  const _SigningModeChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 12),
            vertical: Responsive.w(context, 12),
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.createAccent.withValues(alpha: 0.08)
                : AppColors.createFieldBg,
            borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
            border: Border.all(
              color: selected
                  ? AppColors.createAccent
                  : AppColors.createFieldBorder,
              width: 1.16,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.createFieldValue(context, size: 13)
                    .copyWith(
                      color: selected
                          ? AppColors.createAccent
                          : AppColors.createTitle,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              SizedBox(height: Responsive.w(context, 2)),
              Text(
                subtitle,
                style: AppTextStyles.createRowSubtitle(
                  context,
                ).copyWith(fontSize: Responsive.sp(context, 10)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SigningField extends StatelessWidget {
  const _SigningField({
    required this.label,
    required this.controller,
    this.obscure = false,
  });

  final String label;
  final TextEditingController controller;
  final bool obscure;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.createFieldLabel(context)),
        SizedBox(height: Responsive.w(context, 8)),
        TextField(
          controller: controller,
          obscureText: obscure,
          style: AppTextStyles.createFieldValue(context, size: 14),
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.createFieldBg,
            contentPadding: EdgeInsets.symmetric(
              horizontal: Responsive.w(context, 17.16),
              vertical: Responsive.w(context, 12),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              borderSide: const BorderSide(color: AppColors.createFieldBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              borderSide: const BorderSide(color: AppColors.createFieldBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(Responsive.w(context, 14)),
              borderSide: const BorderSide(color: AppColors.createAccent),
            ),
          ),
        ),
      ],
    );
  }
}
