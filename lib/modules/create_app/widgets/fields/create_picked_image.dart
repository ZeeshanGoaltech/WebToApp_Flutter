import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

bool isAssetImagePath(String path) => path.startsWith('assets/');

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
      );
    }

    if (kIsWeb) {
      return Image.network(imagePath, fit: fit, width: width, height: height);
    }

    return Image.file(
      File(imagePath),
      fit: fit,
      width: width,
      height: height,
    );
  }
}
