import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  static Future<bool> requestAllRequiredPermissions() async {
    // Request notification (Android 13+)
    final notificationStatus = await Permission.notification.request();

    // Request location
    final locationStatus = await Permission.locationWhenInUse.request();

    return notificationStatus.isGranted && locationStatus.isGranted;
  }
}
