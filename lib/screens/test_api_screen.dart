import 'package:flutter/material.dart';
import '../repositories/family_repository.dart';
import '../repositories/camera_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/alert_repository.dart';
import '../repositories/chip_repository.dart';

class TestApiScreen extends StatefulWidget {
  const TestApiScreen({super.key});

  @override
  State<TestApiScreen> createState() => _TestApiScreenState();
}

class _TestApiScreenState extends State<TestApiScreen> {
  final familyRepo = FamilyRepository();
  final chipRepo = ChipRepository();
  final cameraRepo = CameraRepository();
  final sessionRepo = SessionRepository();
  final alertRepo = AlertRepository();

  String log = "";

  void addLog(String text) {
    setState(() {
      log += "$text\n";
    });
  }

  // FULL FLOW TEST
  Future<void> runFullTest() async {
    addLog("===== START FULL TEST =====");

    // 1. CREATE FAMILY
    String? familyId = await familyRepo.createFamily("My Family");
    if (familyId == null) {
      addLog("Family creation failed");
      return;
    }
    addLog("Family ID: $familyId");

    // 2. REGISTER CHIP (giả lập Pi)
    String serial = "PI_001";
    await chipRepo.registerChip(serial);
    addLog("✅ Chip registered: $serial");

    // 3. LINK CHIP → FAMILY
    bool linked = await chipRepo.linkChip(
      serial,
      familyId,
      "Chip phòng khách",
    );

    if (!linked) {
      addLog("Link chip failed");
      return;
    }
    addLog("Chip linked to family");

    // 4. LẤY CHIP ID
    String? chipId;
    await chipRepo.getChips(familyId).first.then((chips) {
      if (chips.isNotEmpty) {
        chipId = chips.first.id;
      }
    });

    if (chipId == null) {
      addLog("Không lấy được chipId");
      return;
    }

    addLog("Chip ID: $chipId");

    // 5. ADD CAMERA
    String? cameraId =
        await cameraRepo.addCamera(familyId, chipId!, "Camera 1");

    if (cameraId == null) {
      addLog("Add camera failed");
      return;
    }

    addLog("Camera ID: $cameraId");

    // 6. LIST CAMERA REALTIME
    cameraRepo.getCameras(familyId).listen((cams) {
      addLog("Cameras: ${cams.length}");
    });

    // 7. UPDATE CAMERA STATUS
    await cameraRepo.updateCameraStatus(cameraId, "online");
    addLog("✅ Camera ONLINE");

    // 8. SESSION TEST
    String? sessionId = await sessionRepo.createSession(cameraId);
    addLog("🎥 Session ID: $sessionId");

    if (sessionId != null) {
      sessionRepo.listenSignals(sessionId).listen((snapshot) {
        for (var doc in snapshot.docs) {
          addLog("📡 Signal: ${doc['type']}");
        }
      });

      await sessionRepo.sendOffer(sessionId, "fake_offer");
      await sessionRepo.sendAnswer(sessionId, "fake_answer");
      await sessionRepo.sendIceCandidate(sessionId, "fake_ice");

      addLog("Sent signaling");
    }

    // 9. ALERT TEST
    alertRepo.listenAlerts(familyId).listen((alerts) {
      addLog("🚨 Alerts: ${alerts.length}");
    });

    await alertRepo.sendFallAlert(familyId, cameraId);
    addLog("Sent FALL ALERT");

    addLog("===== END TEST =====");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Test API")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () async {
                await runFullTest();
              },
              child: const Text("RUN FULL TEST"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(log),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
