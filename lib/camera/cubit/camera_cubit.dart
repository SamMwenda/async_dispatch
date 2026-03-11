import 'package:bloc/bloc.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';

part 'camera_state.dart';

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
      for (var i = 0; i <= 100; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));

        emit(
          state.copyWith(
            status: CameraStatus.checking,
            progress: i / 100,
          ),
        );
      }

      emit(state.copyWith(status: CameraStatus.ready, controller: controller));
    } on CameraException catch (e) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          error: 'Camera issue detected: ${e.description}',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CameraStatus.error,
          error: 'Unexpected error occurred',
        ),
      );
    }
  }

  Future<void> takePicture() async {
    if (state.controller == null || !state.controller!.value.isInitialized) {
      return;
    }

    emit(state.copyWith(status: CameraStatus.capturing));
    try {
      final file = await state.controller!.takePicture();
      emit(state.copyWith(status: CameraStatus.success, capturedImage: file));
    } catch (e) {
      emit(state.copyWith(status: CameraStatus.error, error: e.toString()));
    }
  }

  Future<void> retakePicture() async {
    if (state.status != CameraStatus.retake) {
      try {
        emit(
          state.copyWith(
            status: CameraStatus.retake,
            controller: state.controller,
          ),
        );
      } catch (e) {
        emit(state.copyWith(status: CameraStatus.error, error: e.toString()));
      }
    }
  }

  void reset() {
    emit(state.copyWith(status: CameraStatus.ready));
  }

  @override
  Future<void> close() async {
    await state.controller?.dispose();
    return super.close();
  }
}
