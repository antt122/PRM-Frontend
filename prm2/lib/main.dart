import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'services/audio_player_service.dart';
import 'screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background audio support
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.healink.prm2.channel.audio',
    androidNotificationChannelName: 'Healink Audio',
    androidNotificationOngoing: true,
    androidShowNotificationBadge: true,
  );
  
  // Load the .env file
  await dotenv.load(fileName: ".env");
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AudioPlayerService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Social Network Demo',
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
