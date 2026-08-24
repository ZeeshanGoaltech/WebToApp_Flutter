/// Remembers what to run after the user signs in from a gated flow.
class AuthRedirect {
  AuthRedirect._();

  static Future<void> Function()? _pendingAction;

  static bool get hasPendingAction => _pendingAction != null;

  static void setPendingAction(Future<void> Function() action) {
    _pendingAction = action;
  }

  static Future<void> Function()? takePendingAction() {
    final action = _pendingAction;
    _pendingAction = null;
    return action;
  }
}
