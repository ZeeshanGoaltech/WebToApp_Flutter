enum NavTabType { home, privacyPolicy, whatsapp, externalLink }

enum NavTabMode { webview, browser }

class NavTabModel {
  NavTabModel({
    required this.id,
    required this.type,
    required this.label,
    this.mode = NavTabMode.webview,
  });

  final String id;
  final NavTabType type;
  final String label;
  NavTabMode mode;

  String get iconAsset {
    switch (type) {
      case NavTabType.home:
        return 'home';
      case NavTabType.privacyPolicy:
        return 'shield';
      case NavTabType.whatsapp:
        return 'whatsapp';
      case NavTabType.externalLink:
        return 'link';
    }
  }
}
