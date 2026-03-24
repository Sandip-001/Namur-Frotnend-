import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class ZoomEarthLauncher {
  /// Open ZoomEarth with user’s current location
  static Future<void> openWithCurrentLocation() async {
    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      print("❌ Location permission denied");
      return;
    }

    // Get current location
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    double lat = pos.latitude;
    double lon = pos.longitude;

    // Create ZoomEarth URL (zoom level 7)
    final url = Uri.parse("https://zoom.earth/#view=$lat,$lon,7z");

    try {
      bool launched = await launchUrl(url, mode: LaunchMode.externalApplication);
      if (!launched) {
         launched = await launchUrl(url);
      }
      if (launched) {
        print("🌍 Opening ZoomEarth at: $lat, $lon");
      } else {
        print("❌ Could not launch ZoomEarth");
      }
    } catch (e) {
      print("❌ Error launching ZoomEarth: $e");
    }
  }
}
