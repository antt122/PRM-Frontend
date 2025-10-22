import 'package:flutter/material.dart';
import '../widgets/mini_player.dart';

/// Wrapper layout that adds MiniPlayer at bottom of screen
/// Use this to wrap your main screens (home, profile, etc.)
class LayoutWithMiniPlayer extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Widget? drawer;

  const LayoutWithMiniPlayer({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      backgroundColor: backgroundColor,
      drawer: drawer,
      floatingActionButton: floatingActionButton != null
          ? Padding(
              padding: const EdgeInsets.only(bottom: 70), // Add padding to avoid mini player
              child: floatingActionButton,
            )
          : null,
      body: Column(
        children: [
          // Main content
          Expanded(child: child),
          
          // Mini player at bottom (shows when audio is playing)
          const MiniPlayer(),
        ],
      ),
    );
  }
}
