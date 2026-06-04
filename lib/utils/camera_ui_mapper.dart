import '../models/camera_model.dart' as firestore;
import '../models/models.dart' as ui;

ui.CameraModel toUiCamera(firestore.CameraModel camera) {
  return ui.CameraModel(
    id: camera.id,
    name: camera.name,
    location: camera.chipId.isNotEmpty ? 'Chip ${camera.chipId}' : 'Family',
    status: camera.status == 'online' ? ui.CameraStatus.live : ui.CameraStatus.offline,
    resolution: '—',
    aiEnabled: false,
    cpuLoad: 0,
  );
}

List<ui.CameraModel> toUiCameras(List<firestore.CameraModel> cameras) {
  return cameras.map(toUiCamera).toList();
}
