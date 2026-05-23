import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_locale.dart';

class LocaleService {
  static const _keyLocale = 'app_locale';

  Future<AppLocale> load() async {
    final prefs = await SharedPreferences.getInstance();
    return AppLocale.fromCode(prefs.getString(_keyLocale));
  }

  Future<void> save(AppLocale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLocale, locale.code);
  }
}
