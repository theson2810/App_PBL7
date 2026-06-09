import '../models/camera_model.dart' as firestore;
import '../models/models.dart' as ui;

ui.CameraModel toUiCamera(firestore.CameraModel camera) {
  final location = camera.cameraIp.isNotEmpty
      ? 'Tenda · ${camera.cameraIp}'
      : (camera.chipId.isNotEmpty ? 'Chip ${camera.chipId}' : 'Family');

  return ui.CameraModel(
    id: camera.id,
    name: camera.name,
    location: location,
    status: camera.status == 'online'
        ? ui.CameraStatus.live
        : ui.CameraStatus.offline,
    resolution: camera.cameraIp.isNotEmpty ? '720p' : '—',
    aiEnabled: false,
    cpuLoad: 0,
    relayCameraId: camera.relayCameraId,
  );
}

List<ui.CameraModel> toUiCameras(List<firestore.CameraModel> cameras) {
  return cameras.map(toUiCamera).toList();
}
