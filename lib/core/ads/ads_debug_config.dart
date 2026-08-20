import 'package:flutter/foundation.dart';

/// Debug / QA ad configuration.
///
/// How to get your UMP hashed device ID (required for GDPR form in debug):
/// 1. Run the app once
/// 2. Logcat search: `addTestDeviceHashedId` or `ConsentDebugSettings`
/// 3. Paste the ID into [umpTestDeviceIds] below
///
/// Without your device ID, UMP ignores debug EEA geography and the form
/// will not appear outside the real EEA.
class AdsDebugConfig {
  AdsDebugConfig._();

  /// When `true`, Google **test** ad unit IDs are used in **release** builds too
  /// (and test device IDs are applied). Keep `false` for production store builds.
  static const bool useTestAdsInRelease = false;

  /// Whether the app should request Google test ad units.
  static bool get useTestAdUnits =>
      kDebugMode || (kReleaseMode && useTestAdsInRelease);

  /// [RequestConfiguration.testDeviceIds] — forces Google test ads.
  static const List<String> adMobTestDeviceIds = <String>[
    '00008110-001E09A13EBB601E',
    'B3EEABB8EE11C2BE770B684D95219EFB',
    // Common Android emulator / Google sample hashed ID:
    '33BE2250B43518CCDA7DE426D04EE231',
  ];

  /// [ConsentDebugSettings.testIdentifiers] — enables UMP debug geography.
  static const List<String> umpTestDeviceIds = <String>[
    '00008110-001E09A13EBB601E',
    'B3EEABB8EE11C2BE770B684D95219EFB',
    '33BE2250B43518CCDA7DE426D04EE231',
  ];
}
