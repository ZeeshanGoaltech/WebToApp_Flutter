import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/core/widgets/figma_svg_icon.dart';

/// Figma field: small label on top, value/hint below — no fixed inner flex.
class CreateLabeledField extends StatefulWidget {
  const CreateLabeledField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.trailingIcon,
    this.trailingAsset,
    this.monospace = false,
    this.errorText,
    this.keyboardType,
    this.inputFormatters,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final Widget? trailingIcon;
  final String? trailingAsset;
  final bool monospace;
  final String? errorText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  State<CreateLabeledField> createState() => _CreateLabeledFieldState();
}

class _CreateLabeledFieldState extends State<CreateLabeledField> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant CreateLabeledField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onTextChanged);
      widget.controller.addListener(_onTextChanged);
    }
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _focused => _focusNode.hasFocus;
  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;
  bool get _isNumericKeyboard =>
      widget.keyboardType == TextInputType.number ||
      widget.keyboardType ==
          const TextInputType.numberWithOptions(decimal: true);

  TextStyle _inputStyle(BuildContext context) {
    final base = widget.monospace
        ? AppTextStyles.createPackageField(context)
        : AppTextStyles.createFieldValue(context, size: 16);
    return base.copyWith(height: 1.2);
  }

  @override
  Widget build(BuildContext context) {
    final minHeight = Responsive.w(context, 55.997);
    final radius = Responsive.w(context, 14);
    final borderColor = _hasError
        ? AppColors.createDelete
        : _focused
            ? AppColors.createFieldFocus
            : AppColors.createFieldBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          constraints: BoxConstraints(minHeight: minHeight),
          decoration: BoxDecoration(
            color: AppColors.createFieldBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1.16),
            boxShadow: _focused && !_hasError
                ? [
                    BoxShadow(
                      color: AppColors.createFieldFocus.withValues(alpha: 0.1),
                      spreadRadius: 3,
                    ),
                  ]
                : null,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 17.16),
            vertical: Responsive.w(context, 8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.label,
                      style: AppTextStyles.createFieldLabel(context),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    TextField(
                      controller: widget.controller,
                      focusNode: _focusNode,
                      keyboardType: widget.keyboardType,
                      inputFormatters: widget.inputFormatters,
                      autocorrect: !_isNumericKeyboard,
                      enableSuggestions: !_isNumericKeyboard,
                      spellCheckConfiguration: _isNumericKeyboard
                          ? const SpellCheckConfiguration.disabled()
                          : null,
                      maxLines: 1,
                      textAlignVertical: TextAlignVertical.center,
                      style: _inputStyle(context),
                      decoration: InputDecoration(
                        isDense: true,
                        isCollapsed: true,
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        hintText: widget.hint,
                        hintStyle: AppTextStyles.createFieldHint(context)
                            .copyWith(height: 1.2),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.trailingIcon != null || widget.trailingAsset != null) ...[
                SizedBox(width: Responsive.w(context, 8)),
                widget.trailingIcon ??
                    FigmaSvgIcon(
                      asset: widget.trailingAsset!,
                      size: Responsive.w(context, 19.995),
                    ),
              ],
            ],
          ),
        ),
        if (_hasError)
          Padding(
            padding: EdgeInsets.only(
              top: Responsive.w(context, 6),
              left: Responsive.w(context, 4),
            ),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.createFieldError(context),
            ),
          ),
      ],
    );
  }
}

/// Multi-line field with label on top (onboarding description).
class CreateLabeledTextArea extends StatefulWidget {
  const CreateLabeledTextArea({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.maxLength = 120,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final int maxLength;
  final String? errorText;

  @override
  State<CreateLabeledTextArea> createState() => _CreateLabeledTextAreaState();
}

class _CreateLabeledTextAreaState extends State<CreateLabeledTextArea> {
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() => setState(() {});

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  bool get _hasError =>
      widget.errorText != null && widget.errorText!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final height = Responsive.w(context, 95.988);
    final radius = Responsive.w(context, 14);
    final borderColor = _hasError
        ? AppColors.createDelete
        : _focusNode.hasFocus
            ? AppColors.createFieldFocus
            : AppColors.createFieldBorder;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          decoration: BoxDecoration(
            color: AppColors.createFieldBg,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1.16),
          ),
          padding: EdgeInsets.fromLTRB(
            Responsive.w(context, 17.16),
            Responsive.w(context, 8),
            Responsive.w(context, 17.16),
            Responsive.w(context, 8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.label,
                style: AppTextStyles.createFieldLabel(context),
              ),
              SizedBox(height: Responsive.w(context, 4)),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  maxLines: null,
                  expands: true,
                  maxLength: widget.maxLength,
                  buildCounter: (
                    _, {
                    required currentLength,
                    required isFocused,
                    maxLength,
                  }) =>
                      null,
                  textAlignVertical: TextAlignVertical.top,
                  style: AppTextStyles.createFieldValue(context, size: 14)
                      .copyWith(height: 1.3),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: widget.hint,
                    hintStyle: AppTextStyles.createFieldHint(context)
                        .copyWith(height: 1.3),
                  ),
                ),
              ),
              Text(
                '${widget.controller.text.length}/${widget.maxLength}',
                style: AppTextStyles.createFieldLabel(context),
              ),
            ],
          ),
        ),
        if (_hasError)
          Padding(
            padding: EdgeInsets.only(
              top: Responsive.w(context, 6),
              left: Responsive.w(context, 4),
            ),
            child: Text(
              widget.errorText!,
              style: AppTextStyles.createFieldError(context),
            ),
          ),
      ],
    );
  }
}
