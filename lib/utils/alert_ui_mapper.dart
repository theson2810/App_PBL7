import '../models/alert_model.dart' as firestore;
import '../models/models.dart' as ui;

ui.AlertModel toUiAlert(firestore.AlertModel alert) {
  final type = _mapType(alert.type);
  final isActive = alert.status == 'active';
  final severity = _mapSeverity(alert.type, isActive);

  return ui.AlertModel(
    id: alert.id,
    type: type,
    severity: severity,
    title: _titleFor(alert.type),
    description: alert.message.isNotEmpty
        ? alert.message
        : _defaultMessage(alert.type, alert.cameraId),
    location: alert.cameraId.isNotEmpty ? 'Camera ${alert.cameraId}' : 'System',
    time: alert.createdAt,
    hasSnapshot: false,
  );
}

ui.AlertType _mapType(String type) {
  switch (type.toLowerCase()) {
    case 'fall':
      return ui.AlertType.fallDetected;
    case 'movement':
      return ui.AlertType.irregularMovement;
    case 'boundary':
      return ui.AlertType.boundaryEntry;
    case 'medication':
      return ui.AlertType.medication;
    case 'sleep':
      return ui.AlertType.sleep;
    default:
      return ui.AlertType.fallDetected;
  }
}

ui.AlertSeverity _mapSeverity(String type, bool isActive) {
  if (!isActive) return ui.AlertSeverity.info;
  switch (type.toLowerCase()) {
    case 'fall':
      return ui.AlertSeverity.emergency;
    case 'movement':
      return ui.AlertSeverity.medium;
    case 'boundary':
      return ui.AlertSeverity.notice;
    default:
      return ui.AlertSeverity.high;
  }
}

String _titleFor(String type) {
  switch (type.toLowerCase()) {
    case 'fall':
      return 'Fall Detected';
    case 'movement':
      return 'Irregular Movement';
    case 'boundary':
      return 'Boundary Entry';
    case 'medication':
      return 'Medication Reminder';
    case 'sleep':
      return 'Sleep Pattern Alert';
    default:
      return 'Safety Alert';
  }
}

String _defaultMessage(String type, String cameraId) {
  final cam = cameraId.isNotEmpty ? ' (camera: $cameraId)' : '';
  switch (type.toLowerCase()) {
    case 'fall':
      return 'A fall-type alert was recorded$cam.';
    case 'movement':
      return 'Unusual movement detected$cam.';
    default:
      return 'Alert recorded$cam.';
  }
}

List<ui.AlertModel> toUiAlerts(List<firestore.AlertModel> alerts) {
  return alerts.map(toUiAlert).toList();
}
