// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YiChinese';

  @override
  String get navHome => 'Home';

  @override
  String get navBooks => 'Books';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get loginUsernameLabel => 'Username';

  @override
  String get loginPasswordLabel => 'Password';

  @override
  String get loginSubmit => 'Sign in';

  @override
  String get loginFieldRequired => 'Required';

  @override
  String get loginFailed => 'Sign in failed. Check your username and password.';
}
