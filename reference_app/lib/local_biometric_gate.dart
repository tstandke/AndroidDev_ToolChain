import 'package:firebase_auth/firebase_auth.dart';
import 'package:local_auth/local_auth.dart';

class LocalBiometricGate {
  static final LocalAuthentication _auth = LocalAuthentication();

  static Future<bool> allowAccessIfSignedIn() async {
    // Only gate when a Firebase session exists.
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return true;

    final canCheck = await _auth.canCheckBiometrics;
    final supported = await _auth.isDeviceSupported();

    // If the device cannot do biometrics, do not block the user in dev.
    // (We can tighten this later if desired.)
    if (!supported || !canCheck) return true;

    try {
      return await _auth.authenticate(
        localizedReason: 'Unlock to continue',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
