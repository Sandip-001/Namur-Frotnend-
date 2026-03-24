import 'package:share_plus/share_plus.dart';

class AdShareService {
  /// Shares an ad link using the platform's native share sheet.
  static void shareAd({required String adUid, String? title}) {
    final shareUrl = "https://api.inkaanalysis.com/ad/$adUid";
    final shareText = title != null ? "$title\n$shareUrl" : shareUrl;
    Share.share(shareText);
  }
}
