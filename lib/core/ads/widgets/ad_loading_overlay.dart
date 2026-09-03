import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_to_app/core/ads/ad_presentation_gate.dart';
import 'package:web_to_app/core/ads/widgets/ad_loading_dialog.dart';

/// Root overlay "Loading ad" UI that never participates in the navigator stack.
///
/// Using [OverlayEntry] (instead of [showDialog]) avoids orphan dialogs when
/// routes are pushed/popped while an interstitial is loading.
class AdLoadingOverlay {
  AdLoadingOverlay._();

  static OverlayEntry? _entry;

  static bool get isShowing => _entry != null;

  static void show({String? message}) {
    hide();
    // Drop any leftover showDialog "Loading ad" from older builds.
    clearStaleNavigatorDialogs();

    final ctx = Get.overlayContext ?? Get.context;
    if (ctx == null || !ctx.mounted) return;

    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          const ModalBarrier(
            dismissible: false,
            color: Color(0x80000000),
          ),
          Center(
            child: AdLoadingDialog(message: message),
          ),
        ],
      ),
    );

    overlay.insert(entry);
    _entry = entry;
  }

  static void hide() {
    final entry = _entry;
    _entry = null;
    if (entry == null) return;
    try {
      entry.remove();
    } catch (_) {}
  }

  /// Pops a stuck [showDialog] loader when no ad is actually in progress.
  static void clearStaleNavigatorDialogs() {
    if (AdPresentationGate.interstitialBusy || AdPresentationGate.appOpenBusy) {
      return;
    }

    final nav = Get.key.currentState;
    if (nav == null || !nav.canPop()) return;

    try {
      var removedPopup = false;
      nav.popUntil((route) {
        if (!removedPopup && route is PopupRoute) {
          removedPopup = true;
          return false; // pop this popup
        }
        return true; // stop
      });
    } catch (_) {}
  }
}
