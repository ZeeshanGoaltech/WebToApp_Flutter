import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class CreateAppPickerService {
  CreateAppPickerService._();

  static final ImagePicker _imagePicker = ImagePicker();

  static const _keystoreExtensions = {'jks', 'keystore', 'p12', 'pfx'};

  static Future<String?> pickImageFromGallery() async {
    final file = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return file?.path;
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
