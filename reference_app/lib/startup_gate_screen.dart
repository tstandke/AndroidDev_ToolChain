import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_preflight_screen.dart';
import 'local_biometric_gate.dart';

class StartupGateScreen extends StatefulWidget {
  const StartupGateScreen({super.key});

  @override
  State<StartupGateScreen> createState() => _StartupGateScreenState();
}

class _StartupGateScreenState extends State<StartupGateScreen> {
  bool _busy = true;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Do NOT navigate in initState immediately. Wait until after first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _route();
    });
  }

  Future<void> _route() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      // Not signed in -> go to sign-in flow.
      if (user == null) {
        if (!mounted) return;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthPreflightScreen()),
        );
        return;
      }

      // Signed in -> require local biometric unlock (local only, not identity).
      final allowed = await LocalBiometricGate.allowAccessIfSignedIn();

      if (!mounted) return;

      if (!allowed) {
        setState(() {
          _busy = false;
          _error = 'Biometric unlock was cancelled or failed.';
        });
        return;
      }

      // If allowed, just go to the normal signed-in UI.
      // (Your AuthPreflightScreen file defines SignedInScreen.)
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SignedInScreen(
            googleEmail: user.email ?? '(no email)',
            firebaseEmail: user.email ?? '(no email)',
            firebaseUid: user.uid,
          ),
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'StartupGate failed:\n$e\n\n$st';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Startup Gate')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: _busy
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text('Checking session…'),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Session not unlocked',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 12),
                    if (_error != null) SelectableText(_error!),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const AuthPreflightScreen()),
                        );
                      },
                      child: const Text('Continue to Sign-In'),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
