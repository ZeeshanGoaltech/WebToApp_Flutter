class SigningDto {
  const SigningDto({
    this.signingMode,
    this.upload,
  });

  final String? signingMode;
  final SigningUploadDto? upload;

  bool get isAuto => signingMode == 'auto';
  bool get isUpload => signingMode == 'upload';
  bool get isConfigured => signingMode == 'auto' || signingMode == 'upload';

  factory SigningDto.fromJson(Map<String, dynamic> json) => SigningDto(
        signingMode: json['signingMode'] as String?,
        upload: json['upload'] is Map<String, dynamic>
            ? SigningUploadDto.fromJson(json['upload'] as Map<String, dynamic>)
            : null,
      );
}

class SigningUploadDto {
  const SigningUploadDto({
    this.keyAlias,
    this.hasKeystore,
  });

  final String? keyAlias;
  final bool? hasKeystore;

  factory SigningUploadDto.fromJson(Map<String, dynamic> json) =>
      SigningUploadDto(
        keyAlias: json['keyAlias'] as String?,
        hasKeystore: json['hasKeystore'] as bool?,
      );
}

class SetSigningRequest {
  const SetSigningRequest.auto() : signingMode = 'auto', upload = null;

  SetSigningRequest.upload({
    required String keystorePassword,
    required String keyAlias,
    required String keyPassword,
  })  : signingMode = 'upload',
        upload = SigningUploadCredentials(
          keystorePassword: keystorePassword,
          keyAlias: keyAlias,
          keyPassword: keyPassword,
        );

  final String signingMode;
  final SigningUploadCredentials? upload;

  Map<String, dynamic> toJson() => {
        'signingMode': signingMode,
        if (upload != null) 'upload': upload!.toJson(),
      };
}

class SigningUploadCredentials {
  const SigningUploadCredentials({
    required this.keystorePassword,
    required this.keyAlias,
    required this.keyPassword,
  });

  final String keystorePassword;
  final String keyAlias;
  final String keyPassword;

  Map<String, dynamic> toJson() => {
        'keystorePassword': keystorePassword,
        'keyAlias': keyAlias,
        'keyPassword': keyPassword,
      };
}
