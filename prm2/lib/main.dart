import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';
import 'dart:async';
import 'services/audio_player_service.dart';
import 'screens/splash_screen.dart';
import 'screens/payment_result_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the .env file first
  await dotenv.load(fileName: ".env");

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
      final uri = Uri.parse(link);
      if (uri.scheme == 'healink' &&
          uri.host == 'payment' &&
          uri.pathSegments.contains('result')) {
        // Parse query parameters
        final queryParams = <String, String>{};
        uri.queryParameters.forEach((key, value) {
          queryParams[key] = value;
        });

        print('🔍 Payment result params: $queryParams');

        // Navigate to payment result screen
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PaymentResultScreen(queryParams: queryParams),
            ),
          );
        });
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
        debugShowCheckedModeBanner: false,
        title: 'Healink',
        theme: ThemeData(
          fontFamily: 'Inter',
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B6B3E)),
          useMaterial3: true,
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
