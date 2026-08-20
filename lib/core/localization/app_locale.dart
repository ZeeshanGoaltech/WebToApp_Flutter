import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:web_to_app/modules/language/data/language_data.dart';

/// Maps language screen IDs to GetX locale keys and Flutter [Locale]s.
class AppLocale {
  AppLocale._();

  static Locale toFlutterLocale(String languageId) {
    final normalized = LanguageData.normalizeId(languageId);
    final parts = normalized.split('_');
    if (parts.length != 2) return const Locale('en', 'GB');
    return Locale(parts[0], parts[1].toUpperCase());
  }

  static String toGetXKey(String languageId) {
    final locale = toFlutterLocale(languageId);
    if (locale.countryCode == null || locale.countryCode!.isEmpty) {
      return locale.languageCode;
    }
    return '${locale.languageCode}_${locale.countryCode}';
  }

  static List<Locale> get supportedLocales =>
      LanguageData.languages.map((l) => toFlutterLocale(l.id)).toList();

  static Locale get fallbackLocale =>
      toFlutterLocale(LanguageData.defaultLanguageId);

  static const List<LocalizationsDelegate<dynamic>> localizationDelegates = [
    AppMaterialLocalizationsDelegate(),
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];
}

class AppMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const AppMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    if (GlobalMaterialLocalizations.delegate.isSupported(locale)) {
      return GlobalMaterialLocalizations.delegate.load(locale);
    }
    return SynchronousFuture<MaterialLocalizations>(
      const DefaultMaterialLocalizations(),
    );
  }

  @override
  bool shouldReload(AppMaterialLocalizationsDelegate old) => false;
}
