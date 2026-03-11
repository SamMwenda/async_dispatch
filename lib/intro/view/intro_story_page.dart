// ignore
// ignore_for_file: lines_longer_than_80_chars

import 'dart:async';

import 'package:async_dispatch/camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:google_fonts/google_fonts.dart';

class IntroStoryPage extends StatefulWidget {
  const IntroStoryPage({
    super.key,
  });

  static const route = '/introStoryPage';
  static const name = 'introStoryPage';

  static Widget pageBuilder(BuildContext context, GoRouterState state) {
    return const IntroStoryPage();
  }

  @override
  State<IntroStoryPage> createState() => _IntroStoryPageState();
}

class _IntroStoryPageState extends State<IntroStoryPage> {
  String _displayFullText = '';
  final String _fullStory =
      'Drivers vanish into DEAD ZONES. Elevators. Rural trails. Basements. '
      'No signal? No problem. We built a ROBUST OFFLINE-FIRST SYNC ENGINE. '
      'Actions are INSTANT. Data hits a persistent local queue, retries via EXPONENTIAL BACKOFF, '
      'and saves BATTERY LIFE. Fire and forget.';

  int _charIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      if (_charIndex < _fullStory.length) {
        setState(() {
          _displayFullText += _fullStory[_charIndex];
          _charIndex++;
        });
      } else {
        _timer?.cancel();
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.pushReplacement(CameraActionPage.route);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: _buildStyledText(_displayFullText),
          ),
        ),
      ),
    );
  }

  TextSpan _buildStyledText(String currentText) {
    final keywords = [
      'DEAD ZONES',
      'ROBUST OFFLINE-FIRST SYNC ENGINE',
      'INSTANT',
      'EXPONENTIAL BACKOFF',
      'BATTERY LIFE',
    ];

    final children = <TextSpan>[];
    var remaining = currentText;

    // A simple parser to bold/underline keywords as they type out
    while (remaining.isNotEmpty) {
      var firstMatchIndex = -1;
      var matchedKeyword = '';

      for (final word in keywords) {
        final index = remaining.indexOf(word);
        if (index != -1 && (firstMatchIndex == -1 || index < firstMatchIndex)) {
          firstMatchIndex = index;
          matchedKeyword = word;
        }
      }

      if (firstMatchIndex == -1) {
        children.add(
          TextSpan(
            text: remaining,
            style: GoogleFonts.jetBrainsMono(color: Colors.white70),
          ),
        );
        break;
      } else {
        if (firstMatchIndex > 0) {
          children.add(
            TextSpan(
              text: remaining.substring(0, firstMatchIndex),
              style: GoogleFonts.jetBrainsMono(color: Colors.white70),
            ),
          );
        }
        children.add(
          TextSpan(
            text: matchedKeyword,
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF00FFA3),
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
        );
        remaining = remaining.substring(
          firstMatchIndex + matchedKeyword.length,
        );
      }
    }

    return TextSpan(
      children: children,
      style: const TextStyle(fontSize: 18, height: 1.6),
    );
  }
}
