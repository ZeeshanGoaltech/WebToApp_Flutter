import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:web_to_app/core/theme/app_colors.dart';

bool isAssetImagePath(String path) => path.startsWith('assets/');

bool _isReadableImageFile(String path) {
  try {
    final file = File(path);
    return file.existsSync() && file.lengthSync() > 0;
  } catch (_) {
    return false;
  }
}

class CreatePickedImage extends StatelessWidget {
  const CreatePickedImage({
    super.key,
    required this.imagePath,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final String imagePath;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    if (isAssetImagePath(imagePath)) {
      return Image.asset(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: _errorBuilder,
      );
    }

    if (kIsWeb) {
      return Image.network(
        imagePath,
        fit: fit,
        width: width,
        height: height,
        errorBuilder: _errorBuilder,
      );
    }

    // Empty/missing cache files throw StateError in FileImage before decode;
    // skip Image.file so Crashlytics never sees a fatal FlutterError.
    if (!_isReadableImageFile(imagePath)) {
      return SizedBox(
        width: width,
        height: height,
        child: _errorPlaceholder(),
      );
    }

    return Image.file(
      File(imagePath),
      fit: fit,
      width: width,
      height: height,
      errorBuilder: _errorBuilder,
    );
  }

  Widget _errorBuilder(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) =>
      _errorPlaceholder();

  Widget _errorPlaceholder() {
    return ColoredBox(
      color: AppColors.createFieldBg,
      child: Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.createAccent.withValues(alpha: 0.45),
          size: 28,
        ),
      ),
    );
  }
}
