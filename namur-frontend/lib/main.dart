import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:the_namur_frontend/provider/cropplan_provider.dart';
import 'package:the_namur_frontend/provider/friends_provider.dart';
import 'package:the_namur_frontend/provider/land_district_provider.dart';
import 'package:the_namur_frontend/provider/machinery_ads_provider.dart';
import 'package:the_namur_frontend/provider/my_booking_provider.dart';
import 'package:the_namur_frontend/provider/product_ads_provider.dart';
import 'package:the_namur_frontend/provider/auth_provider.dart';
import 'package:the_namur_frontend/provider/cart_provider.dart';
import 'package:the_namur_frontend/provider/category_provider.dart';
import 'package:the_namur_frontend/provider/crop_calendar_provider.dart';
import 'package:the_namur_frontend/provider/crop_selection_provider.dart';
import 'package:the_namur_frontend/provider/crop_sell_provider.dart';
import 'package:the_namur_frontend/provider/details_expand_provider.dart';
import 'package:the_namur_frontend/provider/details_provider.dart';
import 'package:the_namur_frontend/provider/district_provider.dart';
import 'package:the_namur_frontend/provider/edit_profile_provider.dart';
import 'package:the_namur_frontend/provider/land_product_list_provider.dart';
import 'package:the_namur_frontend/provider/land_product_provider.dart';
import 'package:the_namur_frontend/provider/land_provider.dart';
import 'package:the_namur_frontend/provider/machine_provider.dart';
import 'package:the_namur_frontend/provider/macinery_details_provider.dart';
import 'package:the_namur_frontend/provider/order_tracking_provider.dart';
import 'package:the_namur_frontend/provider/product_provider.dart';
import 'package:the_namur_frontend/provider/product_provider_api.dart';
import 'package:the_namur_frontend/provider/subcategory_ads_provider4.dart';
import 'package:the_namur_frontend/provider/user_provider.dart';
import 'package:the_namur_frontend/provider/weather_provider.dart';
import 'package:the_namur_frontend/screens/seller_ads_provider.dart';
import 'package:the_namur_frontend/screens/splash_screen.dart';
import 'package:the_namur_frontend/utils/app_state.dart';
import 'package:the_namur_frontend/utils/navigation_service.dart';
import 'models/pending_ad.dart';
import 'models/pending_ad_adapter.dart';
import 'provider/language_provider.dart';

/// 🔥 Background FCM handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print("🔥 Background notification received: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light, // Android → white icons
      statusBarBrightness: Brightness.light, // iOS → white text
    ),
  );

  print("🔥 Firebase initialized");


  await EasyLocalization.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(PendingAdAdapter());
  // 🔒 Lock orientation to Portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await Hive.openBox<PendingAd>("pending_ads");
  /// 🔥 Register background notification handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('ta', 'IN'),
        Locale('kn', 'IN'),
        Locale('hi', 'IN'),
        Locale('te', 'IN'),
        Locale('ml', 'IN'),
        Locale('mr', 'IN'),
        Locale('bn', 'IN'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en', 'US'),
      saveLocale: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => ProductProviderDemo()),
          ChangeNotifierProvider(create: (_) => ProductProvider()),
          ChangeNotifierProvider(create: (_) => MachineProvider()),
          ChangeNotifierProvider(create: (_) => AppState()),
          ChangeNotifierProvider(create: (_) => CropSelectionProvider()),
          ChangeNotifierProvider(create: (_) => CropCalendarProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderTrackingProvider()),
          ChangeNotifierProvider(create: (_) => DetailsProvider()),
          ChangeNotifierProvider(create: (_) => DetailsExpandProvider()),
          ChangeNotifierProvider(create: (_) => SubCategoryAdsProvider()),
          ChangeNotifierProvider(create: (_) => CategoryProvider()),
          ChangeNotifierProvider(create: (_) => ProfileProvider()),
          ChangeNotifierProvider(create: (_) => UserProvider()),
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => DistrictProvider()),
          ChangeNotifierProvider(create: (_) => LandDetailsProvider()),
          ChangeNotifierProvider(create: (_) => LandProductProvider()),
          ChangeNotifierProvider(create: (_) => LandProductListProvider()),
          ChangeNotifierProvider(create: (_) => CropSellProvider()),
          ChangeNotifierProvider(create: (_) => MachineryProvider()),
          ChangeNotifierProvider(create: (_) => ProductAdsProvider()),
          ChangeNotifierProvider(create: (_) => MachineryAdsProvider()),
          ChangeNotifierProvider(create: (_) => FriendsProvider()),
          ChangeNotifierProvider(create: (_) => CropPlanProvider()),
          ChangeNotifierProvider(create: (_) => LandDistrictProvider()),
          ChangeNotifierProvider(create: (_) => SellerAdsProvider()),
          ChangeNotifierProvider(create: (_) => MyBookingsProvider()),
          ChangeNotifierProvider(create: (_) => WeatherProvider()..fetchWeather()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    setupFCM();
  }

  /// 🔥 FULL FCM SETUP
  Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    /// (1) Ask permission
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print("🔔 Notification Permission: ${settings.authorizationStatus}");

    /// (2) Get the FCM Token
    String? token = await messaging.getToken();
    print("📌 FCM Token: $token");

    /// Save token to backend
    if (token != null) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      await auth.saveFcmToken();
    }

    /// (3) Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("📩 Foreground notification: ${message.notification?.title}");
    });

    /// (4) When user taps notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("📨 Notification opened: ${message.notification?.title}");
    });
  }
  final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
  GlobalKey<ScaffoldMessengerState>();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Colors.orange,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'app_title'.tr(),
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: SplashScreen(),
    );
  }
}
