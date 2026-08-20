import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';
import 'package:web_to_app/modules/language/models/language_option.dart';

class LanguageTile extends StatelessWidget {
  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  final LanguageOption language;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = Responsive.w(context, 16);
    final borderWidth = Responsive.w(context, 1);
    final flagWidth = Responsive.w(context, 40);
    final flagHeight = Responsive.w(context, 28);
    final flagRadius = Responsive.w(context, 6);
    final checkSize = Responsive.w(context, 22);

    final nameStyle = AppTextStyles.languageItemName(context).copyWith(
      color: isSelected ? Colors.white : AppColors.title,
    );
    final countryStyle = AppTextStyles.languageItemCountry(context).copyWith(
      color: isSelected
          ? Colors.white.withValues(alpha: 0.85)
          : AppColors.subtitle,
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: Responsive.w(context, 14),
            vertical: Responsive.w(context, 14),
          ),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.languageUnselectedBorder,
              width: borderWidth,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(flagRadius),
                child: SizedBox(
                  width: flagWidth,
                  height: flagHeight,
                  child: CountryFlag.fromCountryCode(
                    language.countryCode,
                    theme: ImageTheme(
                      width: flagWidth,
                      height: flagHeight,
                      shape: RoundedRectangle(flagRadius),
                    ),
                  ),
                ),
              ),
              SizedBox(width: Responsive.w(context, 12)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      language.languageName,
                      style: nameStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: Responsive.w(context, 2)),
                    Text(
                      language.countryName,
                      style: countryStyle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (isSelected) ...[
                SizedBox(width: Responsive.w(context, 8)),
                Container(
                  width: checkSize,
                  height: checkSize,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: Responsive.w(context, 14),
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
