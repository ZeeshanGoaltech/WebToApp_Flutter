import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:web_to_app/core/ads/ads_debug_config.dart';

/// GDPR / EEA messaging via Google UMP (same flow as Ummah_Pro_Exis).
///
/// Debug: reset every launch + force EEA + force-show form when available.
/// Release: normal UMP geography / expiry rules.
class GdprConsentService {
  GdprConsentService._();

  static final GdprConsentService instance = GdprConsentService._();

  bool _gatheredThisSession = false;

  Future<void> gatherConsent() async {
    if (_gatheredThisSession) return;
    if (!Platform.isAndroid && !Platform.isIOS) return;
    _gatheredThisSession = true;

    // Let FlutterActivity attach before presenting the UMP dialog.
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final params = kDebugMode
        ? ConsentRequestParameters(
            consentDebugSettings: ConsentDebugSettings(
              debugGeography: DebugGeography.debugGeographyEea,
              testIdentifiers: List<String>.from(AdsDebugConfig.umpTestDeviceIds),
            ),
          )
        : ConsentRequestParameters();

    if (kDebugMode) {
      try {
        await ConsentInformation.instance.reset();
        developer.log('[GDPR] reset (debug) — form should show every launch');
        // Brief pause so native UMP clears persisted state before update.
        await Future<void>.delayed(const Duration(milliseconds: 200));
      } catch (e, st) {
        developer.log('[GDPR] reset failed (ignored): $e', stackTrace: st);
      }
    }

    final completer = Completer<void>();

    void finish() {
      if (!completer.isCompleted) completer.complete();
    }

    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
      () {
        Future(() async {
          try {
            final status = await ConsentInformation.instance.getConsentStatus();
            final available =
                await ConsentInformation.instance.isConsentFormAvailable();
            developer.log(
              '[GDPR] after update: status=$status available=$available '
              '(debug=$kDebugMode)',
            );

            if (kDebugMode && available) {
              // Force present so we don't rely solely on "if required"
              // (debug geography only applies when the device is in
              // [AdsDebugConfig.umpTestDeviceIds] — check logcat for the ID).
              await _forceShowConsentForm();
            } else {
              await ConsentForm.loadAndShowConsentFormIfRequired((formError) {
                if (formError != null) {
                  developer.log(
                    '[GDPR] Consent form: ${formError.message}',
                  );
                }
              });
            }

            if (kDebugMode && !available) {
              developer.log(
                '[GDPR] No consent form available. Create a GDPR message in '
                'AdMob → Privacy & messaging for this app, and add your '
                'UMP test device hashed ID from logcat to AdsDebugConfig.',
              );
            }
          } catch (e, st) {
            developer.log(
              '[GDPR] present form failed: $e',
              error: e,
              stackTrace: st,
            );
          } finally {
            finish();
          }
        });
      },
      (FormError error) {
        developer.log(
          '[GDPR] requestConsentInfoUpdate: ${error.errorCode} ${error.message}',
        );
        if (error.errorCode == 3 ||
            error.message.toLowerCase().contains('no form')) {
          developer.log(
            '[GDPR] ACTION REQUIRED: In AdMob → Privacy & messaging, '
            'create a GDPR message and publish it for app ID '
            'ca-app-pub-5471933816484694~2858628432. '
            'Until then the consent form cannot appear.',
          );
        }
        finish();
      },
    );

    try {
      await completer.future.timeout(const Duration(seconds: 60));
    } on TimeoutException {
      developer.log('[GDPR] Consent flow timed out');
    }
  }

  /// Debug-only: load and show the form even after a previous consent choice.
  Future<void> _forceShowConsentForm() async {
    final shown = Completer<void>();

    ConsentForm.loadConsentForm(
      (ConsentForm form) {
        form.show((FormError? formError) {
          if (formError != null) {
            developer.log(
              '[GDPR] force show error: ${formError.errorCode} '
              '${formError.message}',
            );
          } else {
            developer.log('[GDPR] force-show form dismissed');
          }
          if (!shown.isCompleted) shown.complete();
        });
      },
      (FormError error) {
        developer.log(
          '[GDPR] loadConsentForm failed: ${error.errorCode} ${error.message}',
        );
        // Fallback to standard path.
        ConsentForm.loadAndShowConsentFormIfRequired((formError) {
          if (formError != null) {
            developer.log('[GDPR] fallback form: ${formError.message}');
          }
          if (!shown.isCompleted) shown.complete();
        });
      },
    );

    await shown.future.timeout(
      const Duration(seconds: 55),
      onTimeout: () {
        developer.log('[GDPR] force-show timed out');
      },
    );
  }
}
