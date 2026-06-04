import '../models/alert_model.dart' as firestore;
import '../models/models.dart' as ui;

ui.LogEntry alertToLog(firestore.AlertModel alert) {
  ui.LogLevel level;
  switch (alert.type.toLowerCase()) {
    case 'fall':
      level = alert.status == 'active' ? ui.LogLevel.error : ui.LogLevel.warning;
      break;
    default:
      level = alert.status == 'active' ? ui.LogLevel.warning : ui.LogLevel.info;
  }

  return ui.LogEntry(
    id: alert.id,
    level: level,
    message: alert.message.isNotEmpty
        ? alert.message
        : '${alert.type} alert (${alert.status})',
    detail: alert.cameraId.isNotEmpty ? 'Camera ${alert.cameraId}' : null,
    time: alert.createdAt,
  );
}

List<ui.LogEntry> alertsToLogs(List<firestore.AlertModel> alerts) {
  return alerts.map(alertToLog).toList();
}
