import 'dart:io';

import 'package:async_dispatch/camera/camera.dart';
import 'package:async_dispatch/loading/loading.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class CameraActionPage extends StatelessWidget {
  const CameraActionPage({super.key});

  static const route = '/cameraActionPage';
  static const name = 'cameraActionPage';

  static Widget pageBuilder(BuildContext context, GoRouterState state) {
    return BlocProvider(
      create: (context) => CameraCubit()..initialize(),
      child: const CameraActionPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ASYNC DISPATCH')),
      body: BlocBuilder<CameraCubit, CameraState>(
        builder: (context, state) {
          // 1. No Permission View
          if (state.status == CameraStatus.noPermission) {
            return const Text('Waiting for camera permissions...');
          }

          // 2. Error View
          if (state.status == CameraStatus.error) {
            return Text('Error: ${state.error}');
          }

          // 3. Main Camera/Preview View
          return Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _buildCameraContent(state),
                  ),
                ),
              ),
              _buildActionButtons(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCameraContent(CameraState state) {
    if (state.capturedImage != null && state.status != CameraStatus.retake) {
      return Image.file(File(state.capturedImage!.path), fit: BoxFit.cover);
    }
    if (state.controller != null && state.controller!.value.isInitialized) {
      return CameraPreview(state.controller!);
    }

    if (state.status != CameraStatus.retake &&
        state.controller != null &&
        state.capturedImage != null) {
      return CameraPreview(state.controller!);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedProgressBar(
            progress: state.progress,
            backgroundColor: const Color(0xFF003B2F),
            foregroundColor: const Color(0xFF00FFA3),
          ),
          Text(
            'Initializing Camera ...',
            style: GoogleFonts.jetBrainsMono(
              color: const Color(0xFF00FFA3),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, CameraState state) {
    return state.capturedImage == null || state.status == CameraStatus.retake
        ? Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: ActionButton(
                backgroundColor: const Color(0xFF00FFA3),
                icon: Icons.camera,
                actionText: 'TAKE PHOTO',
                action: () => context.read<CameraCubit>().takePicture(),
              ),
            ),
          )
        : Stack(
            children: [
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 120),
                  child: ActionButton(
                    backgroundColor: const Color(0xFF00FFA3),
                    icon: Icons.flash_on,
                    actionText: 'COMPLETE DISPATCH',
                    action: () {},
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: ActionButton(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 76),
                    icon: Icons.repeat,
                    actionText: 'RETAKE PHOTO',
                    action: () => context.read<CameraCubit>().retakePicture(),
                  ),
                ),
              ),
            ],
          );
  }
}
