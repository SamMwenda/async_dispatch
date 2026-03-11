part of 'camera_cubit.dart';

enum CameraStatus {
  checking,
  noPermission,
  ready,
  capturing,
  success,
  error,
  retake,
}

class CameraState {
  CameraState({
    required this.status,
    required this.progress,
    this.controller,
    this.capturedImage,
    this.error,
  });

  // Factory for initial state
  factory CameraState.initial() =>
      CameraState(status: CameraStatus.checking, progress: 0);
  final CameraStatus status;
  final double progress;
  final CameraController? controller;
  final XFile? capturedImage;
  final String? error;

  CameraState copyWith({
    CameraStatus? status,
    double? progress,
    CameraController? controller,
    XFile? capturedImage,
    String? error,
  }) {
    return CameraState(
      progress: progress ?? this.progress,
      status: status ?? this.status,
      controller: controller ?? this.controller,
      capturedImage: capturedImage ?? this.capturedImage,
      error: error ?? this.error,
    );
  }
}
