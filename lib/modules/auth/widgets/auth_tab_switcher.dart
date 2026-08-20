import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/theme/app_colors.dart';
import 'package:web_to_app/core/theme/app_text_styles.dart';
import 'package:web_to_app/core/utils/responsive.dart';

class AuthTabSwitcher extends StatelessWidget {
  const AuthTabSwitcher({
    super.key,
    required this.isSignIn,
    required this.onSignInTap,
    required this.onSignUpTap,
  });

  final bool isSignIn;
  final VoidCallback onSignInTap;
  final VoidCallback onSignUpTap;

  @override
  Widget build(BuildContext context) {
    final padding = Responsive.w(context, 4.577);
    final tabHeight = Responsive.w(context, 50.341);
    final tabRadius = Responsive.w(context, 25.172);
    final trackRadius = Responsive.w(
      context,
      isSignIn ? 69 : 71,
    );
    final shadowOffset1 = Responsive.w(context, 1.144);
    final shadowBlur1 = Responsive.w(context, 1.716);
    final shadowBlur2 = Responsive.w(context, 1.144);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.authTabTrack,
        borderRadius: BorderRadius.circular(trackRadius),
      ),
      padding: EdgeInsets.all(padding),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final tabWidth = (constraints.maxWidth - padding * 0) / 2;
          return SizedBox(
            height: tabHeight,
            child: Stack(
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeInOut,
                  alignment:
                      isSignIn ? Alignment.centerLeft : Alignment.centerRight,
                  child: Container(
                    width: tabWidth,
                    height: tabHeight,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(tabRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: Offset(0, shadowOffset1),
                          blurRadius: shadowBlur1,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          offset: Offset(0, shadowOffset1),
                          blurRadius: shadowBlur2,
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: onSignInTap,
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'sign_in'.tr,
                            style: isSignIn
                                ? AppTextStyles.authTabActive(context)
                                : AppTextStyles.authTabInactive(context),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: onSignUpTap,
                        behavior: HitTestBehavior.opaque,
                        child: Center(
                          child: Text(
                            'sign_up'.tr,
                            style: !isSignIn
                                ? AppTextStyles.authTabActive(context)
                                : AppTextStyles.authTabInactive(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
