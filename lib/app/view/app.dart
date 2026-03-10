import 'dart:async';
import 'dart:io';

import 'package:async_dispatch/counter/counter.dart';
import 'package:async_dispatch/l10n/l10n.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CounterPage(),
    );
  }
}

class AsyncDispatchApp extends StatelessWidget {
  final CameraDescription camera;
  const AsyncDispatchApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        primaryColor: const Color(0xFF00FFA3),
      ),
      home: IntroStoryScreen(camera: camera),
    );
  }
}

// --- 1. The Thrilling Intro (Typing Animation) ---
class IntroStoryScreen extends StatefulWidget {
  final CameraDescription camera;
  const IntroStoryScreen({super.key, required this.camera});

  @override
  State<IntroStoryScreen> createState() => _IntroStoryScreenState();
}

class _IntroStoryScreenState extends State<IntroStoryScreen> {
  String _displayFullText = "";
  final String _fullStory =
      "Drivers vanish into DEAD ZONES. Elevators. Rural trails. Basements. "
      "No signal? No problem. We built a ROBUST OFFLINE-FIRST SYNC ENGINE. "
      "Actions are INSTANT. Data hits a persistent local queue, retries via EXPONENTIAL BACKOFF, "
      "and saves BATTERY LIFE. Fire and forget.";

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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => CameraActionScreen(),
            ),
          );
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
    final List<String> keywords = [
      "DEAD ZONES",
      "ROBUST OFFLINE-FIRST SYNC ENGINE",
      "INSTANT",
      "EXPONENTIAL BACKOFF",
      "BATTERY LIFE",
    ];

    List<TextSpan> children = [];
    String remaining = currentText;

    // A simple parser to bold/underline keywords as they type out
    while (remaining.isNotEmpty) {
      int firstMatchIndex = -1;
      String matchedKeyword = "";

      for (var word in keywords) {
        int index = remaining.indexOf(word);
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

// --- 2. The Camera/Action Screen ---
class CameraActionScreen extends StatelessWidget {
  const CameraActionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CameraCubit()..initialize(),
      child: Scaffold(
        appBar: AppBar(title: const Text("ASYNC DISPATCH")),
        body: BlocBuilder<CameraCubit, CameraState>(
          builder: (context, state) {
            // 1. No Permission View
            if (state.status == CameraStatus.noPermission) {
              return Text("Waiting for camera permissions...");
            }

            // 2. Error View
            if (state.status == CameraStatus.error) {
              return Text("Error: ${state.error}");
            }

            // 3. Main Camera/Preview View
            return Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: AspectRatio(
                        aspectRatio: 3 / 4,
                        child: _buildCameraContent(state),
                      ),
                    ),
                  ),
                ),
                _buildActionButtons(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCameraContent(CameraState state) {
    if (state.capturedImage != null) {
      return Image.file(File(state.capturedImage!.path), fit: BoxFit.cover);
    }
    if (state.controller != null && state.controller!.value.isInitialized) {
      return CameraPreview(state.controller!);
    }
    return const Center(child: CircularProgressIndicator(color: Color(0xFF00FFA3)));
  }

  Widget _buildActionButtons(BuildContext context, CameraState state) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom:60),
        child: state.capturedImage == null
            ? _shutterButton(context)
            : _completeButton(),
      ),
    );
  }

  Widget _shutterButton( BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: GestureDetector(
          onTap: ()=>context.read<CameraCubit>().takePicture(),
          child: Container(
            height: 80,
            width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
            ),
            child: Center(
              child: Container(
                height: 60,
                width: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF00FFA3),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _completeButton() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0, end: 1),
          duration: const Duration(milliseconds: 500),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Implementation for background sync
                },
                icon: const Icon(Icons.flash_on, color: Colors.black),
                label: Text(
                  "COMPLETE DISPATCH",
                  style: GoogleFonts.montserrat(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFA3),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

enum CameraStatus { checking, noPermission, ready, capturing, success, error }

class CameraState {
  final CameraStatus status;
  final CameraController? controller;
  final XFile? capturedImage;
  final String? error;

  CameraState({
    required this.status,
    this.controller,
    this.capturedImage,
    this.error,
  });

  // Factory for initial state
  factory CameraState.initial() => CameraState(status: CameraStatus.checking);

  CameraState copyWith({
    CameraStatus? status,
    CameraController? controller,
    XFile? capturedImage,
    String? error,
  }) {
    return CameraState(
      status: status ?? this.status,
      controller: controller ?? this.controller,
      capturedImage: capturedImage ?? this.capturedImage,
      error: error ?? this.error,
    );
  }
}

class CameraCubit extends Cubit<CameraState> {
  CameraCubit() : super(CameraState.initial());

  Future<void> initialize() async {
    // 1. Check Permission
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      status = await Permission.camera.request();
    }

    if (!status.isGranted) {
      emit(state.copyWith(status: CameraStatus.noPermission));
      return;
    }

    // 2. Initialize Camera
    try {
      final cameras = await availableCameras();
      final controller = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      emit(state.copyWith(status: CameraStatus.ready, controller: controller));
    } catch (e) {
      emit(state.copyWith(status: CameraStatus.error, error: e.toString()));
    }
  }

  Future<void> takePicture() async {
    if (state.controller == null || !state.controller!.value.isInitialized) return;

    emit(state.copyWith(status: CameraStatus.capturing));
    try {
      final file = await state.controller!.takePicture();
      emit(state.copyWith(status: CameraStatus.success, capturedImage: file));
    } catch (e) {
      emit(state.copyWith(status: CameraStatus.error, error: e.toString()));
    }
  }

  void reset() {
    emit(state.copyWith(status: CameraStatus.ready, capturedImage: null));
  }

  @override
  Future<void> close() {
    state.controller?.dispose();
    return super.close();
  }
}