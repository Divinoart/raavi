import 'dart:io';

class AdManager {
  static String get appId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1396258455588539~2849139983";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1396258455588539~8652192047";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1396258455588539/3167885945";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1396258455588539/1493555624";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }

  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-1396258455588539/2157375387";
    } else if (Platform.isIOS) {
      return "ca-app-pub-1396258455588539/6591444418";
    } else {
      throw new UnsupportedError("Unsupported platform");
    }
  }
}
