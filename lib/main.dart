import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

// SERVICES
import 'services/auth_service.dart';
import 'services/family_service.dart';
import 'services/camera_service.dart';
import 'services/session_service.dart';
import 'services/alert_service.dart';
import 'services/notification_service.dart';
import 'services/realtime_service.dart';

// MODELS
import 'models/alert_model.dart';
//REPOSITORY
import 'repositories/auth_repository.dart';
//TEST API
import 'screens/test_api_screen.dart';
// UI
import 'theme/app_theme.dart';
import 'screens/server/server_app.dart';
import 'screens/client/client_app.dart';


/// TEST AUTH
Future<void> testAuth() async {
  AuthService auth = AuthService();

  var user = await auth.signUp(
    "test@gmail.com",
    "12345678",
  );

  user ??= await auth.signIn(
    "test@gmail.com",
    "12345678",
  );

  print("USER ID: ${user?.uid}");
}

/// TEST FAMILY
Future<void> testFamily() async {
  FamilyService service = FamilyService();

  String? familyId =
      await service.createFamily("My Home");

  print("FAMILY ID: $familyId");

  if (familyId == null) return;
}

/// TEST CAMERA
Future<void> testCamera() async {
  CameraService service = CameraService();

  String familyId = "PUT_FAMILY_ID";

  String? cameraId =
      await service.addCamera(
    familyId,
    "Living Room",
  );

  print("CAMERA ID: $cameraId");
}

/// TEST SESSION
Future<void> testSession() async {
  SessionService service = SessionService();

  String cameraId = "PUT_CAMERA_ID";

  String? sessionId =
      await service.createSession(cameraId);

  print("SESSION ID: $sessionId");
}

/// TEST ALERT
Future<void> testAlert() async {
  AlertService service = AlertService();

  await service.sendFallAlert(
    "PUT_FAMILY_ID",
    "PUT_CAMERA_ID",
  );

  print("FALL ALERT SENT");
}


/// TEST REALTIME (MODEL)
Future<void> testRealtime() async {
  AlertService service = AlertService();

  service.listenAlerts("PUT_FAMILY_ID")
      .listen((List<AlertModel> alerts) {

    for (var alert in alerts) {
      print("REALTIME ALERT: ${alert.message}");
    }

  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  /// CHẠY UI TRƯỚC
  runApp(const ElderlyCareApp());

  ///CHẠY TEST SAU (không block UI)
  Future.microtask(() async {
    await testAuth();
    await NotificationService().initFCM();

    // await testFamily();
    // await testCamera();
    // await testSession();
    // await testAlert();
    // await testRealtime();

    //final authRepo = AuthRepository();
    // TEST SIGN UP
    //await authRepo.signUp("test@gmail.com", "123456");
    // TEST LOGIN
    //await authRepo.signIn("test@gmail.com", "123456");
    // GET USER
    //final user = authRepo.getCurrentUser();
    //print(user?.uid);

  });
}


/// UI APP
class ElderlyCareApp extends StatefulWidget {
  const ElderlyCareApp({super.key});

  @override
  State<ElderlyCareApp> createState() => _ElderlyCareAppState();
}

class _ElderlyCareAppState extends State<ElderlyCareApp> {
  bool _isServerApp = true;

  void _switchApp() {
    setState(() => _isServerApp = !_isServerApp);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _isServerApp ? 'Clinical Sentinel' : 'Vital Horizon',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: TestApiScreen(),
      //home: ClientApp(onSwitchApp: () {}),
/*      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _isServerApp
            ? ServerApp(
                key: const ValueKey('server'),
                onSwitchApp: _switchApp,
              )
            : ClientApp(
                key: const ValueKey('client'),
                onSwitchApp: _switchApp,
              ),
      ),
      */
    );
  }
}