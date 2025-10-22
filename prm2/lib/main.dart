import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'services/audio_player_service.dart';
import 'services/token_manager.dart';
import 'services/auth_service.dart';
import 'screens/splash_screen.dart';
import 'screens/payment_result_screen.dart';
import 'screens/search_podcasts_screen.dart';
import 'screens/my_subscription_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file first
  await dotenv.load(fileName: ".env");

  // Initialize TokenManager
  await TokenManager.instance.initialize();

  // Skip JustAudioBackground.init() for now to avoid initialization issues
  // We'll use regular just_audio instead
  print('🚀 Starting app without background audio service');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription? _linkSubscription;
  final AppLinks _appLinks = AppLinks();
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    // Handle deep links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(
      (Uri uri) {
        print('🔗 Deep link received: $uri');
        _handleDeepLink(uri.toString());
      },
      onError: (err) {
        print('❌ Deep link error: $err');
      },
    );

    // Handle deep link when app is launched
    _appLinks.getInitialLink().then((Uri? uri) {
      if (uri != null) {
        print('🔗 Initial deep link: $uri');
        _handleDeepLink(uri.toString());
      }
    });
  }

  void _handleDeepLink(String link) {
    try {
      print('🔗 Processing deep link: $link');
      final uri = Uri.parse(link);
      print(
        '🔍 Parsed URI - Scheme: ${uri.scheme}, Host: ${uri.host}, Path: ${uri.path}',
      );

      if (uri.scheme == 'healink' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('result')) {
        print('✅ Valid payment result deep link detected!');

        // Parse query parameters
        final queryParams = <String, String>{};
        uri.queryParameters.forEach((key, value) {
          queryParams[key] = value;
        });

        print('🔍 Payment result params: $queryParams');

        // Navigate to payment result screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          print('🚀 Navigating to PaymentResultScreen...');

          // Use navigatorKey to get the correct context
          final navigator = _navigatorKey.currentState;
          if (navigator != null) {
            // Clear all previous routes and navigate to PaymentResultScreen
            navigator.pushAndRemoveUntil(
              MaterialPageRoute(
                builder: (context) =>
                    PaymentResultScreen(queryParams: queryParams),
              ),
              (route) => false, // Remove all previous routes
            );
          } else {
            print('❌ Navigator not available');
          }
        });
      } else {
        print('❌ Deep link does not match payment result pattern');
        print('   Expected: healink://payment/result');
        print('   Received: ${uri.scheme}://${uri.host}${uri.path}');
      }
    } catch (e) {
      print('❌ Error handling deep link: $e');
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerService(),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'Healink',
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B6B3E)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
        routes: {
          '/search': (context) => const SearchPodcastsScreen(),
          '/my-subscription': (context) => const MySubscriptionScreen(),
        },
        builder: (context, child) {
          // Set navigator key for AuthService
          AuthService.instance.setNavigatorKey(_navigatorKey);
          return child!;
        },
      ),
    );
  }
}
