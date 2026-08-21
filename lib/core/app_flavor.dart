import 'package:my_teacher_wallet/core/app_config.dart';

enum Flavor {
  dev,
  prod,
}

class AppFlavor {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.dev:
        return 'Teacher Wallet DEV';
      case Flavor.prod:
        return 'Teacher Wallet';
      default:
        return 'title';
    }
  }

  static String _updatedBaseUrl = "";

  static changeBaseUrl(String value){
    _updatedBaseUrl = value;
  }

  static String get defaultBaseUrl {
    switch (appFlavor) {
      case Flavor.dev:
        return AppConfig.supabaseUrl;
      case Flavor.prod:
        return AppConfig.supabaseUrl;
      default:
        return '';
    }
  }

  static String get baseUrl {
    if (_updatedBaseUrl.isNotEmpty && _updatedBaseUrl != defaultBaseUrl){
      return _updatedBaseUrl;
    } else {
      return defaultBaseUrl;
    }
  }

}
