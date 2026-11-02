import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class ReminderAlertPayload114 {
  final String title;
  final String message;
  final String soundProfile;
  final DateTime triggeredAt;

  const ReminderAlertPayload114({
    required this.title,
    required this.message,
    required this.soundProfile,
    required this.triggeredAt,
  });
}

class ReminderNotificationService114 {
  ReminderNotificationService114._();

  static Future<bool> ensureNotificationPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.notification.status;
      if (status.isGranted) return true;
      final req = await Permission.notification.request();
      return req.isGranted;
    } catch (_) {
      return true;
    }
  }

  static Future<bool> ensureCameraPermission() async {
    if (kIsWeb) return true;
    try {
      final status = await Permission.camera.status;
      if (status.isGranted) return true;
      final req = await Permission.camera.request();
      return req.isGranted;
    } catch (_) {
      return true;
    }
  }

  static Future<ReminderAlertPayload114> triggerReadingReminder({
    required String soundProfile,
    required int completedMinutes,
    required int goalMinutes,
    String? activeDocTitle,
  }) async {
    await ensureNotificationPermission();

    if (soundProfile != 'Silent Mode') {
      try {
        await SystemSound.play(SystemSoundType.alert);
        await HapticFeedback.mediumImpact();
      } catch (_) {}
    }

    final remaining = (goalMinutes - completedMinutes).clamp(0, 999);
    final msg = remaining == 0
        ? 'Daily reading target ($goalMinutes min) achieved! Keep your streak alive.'
        : '$remaining min left to hit your $goalMinutes min daily goal'
            '${activeDocTitle != null ? ' • Resume "$activeDocTitle"' : '.'}';

    return ReminderAlertPayload114(
      title: 'Nexus Reading Goal Reminder ($soundProfile)',
      message: msg,
      soundProfile: soundProfile,
      triggeredAt: DateTime.now(),
    );
  }
}
