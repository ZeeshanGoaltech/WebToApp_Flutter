import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateAppPickerService {
  CreateAppPickerService._();

  static final ImagePicker _imagePicker = ImagePicker();
  static bool _imagePickInFlight = false;

  static const _keystoreExtensions = {'jks', 'keystore', 'p12', 'pfx'};

  static Future<String?> pickImageFromGallery() async {
    if (_imagePickInFlight) return null;
    _imagePickInFlight = true;
    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 90,
      );
      final path = picked?.path;
      if (path == null) return null;

      final file = File(path);
      if (!await file.exists() || await file.length() == 0) {
        return null;
      }
      return path;
    } on PlatformException {
      // Includes already_active / multiple_request while resize is in flight.
      return null;
    } catch (_) {
      return null;
    } finally {
      _imagePickInFlight = false;
    }
  }

  static Future<({String path, String name})?> pickKeystoreFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
        withData: false,
      );

      if (result == null || result.files.isEmpty) return null;

      final file = result.files.first;
      final path = file.path;
      if (path == null) return null;

      final name = file.name;
      final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';
      if (ext.isNotEmpty && !_keystoreExtensions.contains(ext)) {
        throw PlatformException(
          code: 'invalid_keystore',
          message: 'choose_keystore_file'.tr,
        );
      }

      return (path: path, name: name);
    } on PlatformException {
      rethrow;
    }
  }
}
