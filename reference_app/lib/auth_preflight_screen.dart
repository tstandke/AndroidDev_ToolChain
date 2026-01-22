// lib/auth_preflight_screen.dart
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Set this to the *Web application* OAuth Client ID (type 3) from your
/// Google Cloud Console / Firebase-linked project.
const String kServerClientId =
    '883224591051-apnl4fdr2on5ar1d1pbhfk2fpoi0ldle.apps.googleusercontent.com';

/// Keep this minimal and explicit for diagnostics.
const List<String> kRequestedScopes = <String>[
  'openid',
  'email',
  'profile',
];

class AuthPreflightScreen extends StatefulWidget {
  const AuthPreflightScreen({super.key});

  @override
  State<AuthPreflightScreen> createState() => _AuthPreflightScreenState();
}

class _AuthPreflightScreenState extends State<AuthPreflightScreen> {
  PackageInfo? _pkg;
  String? _error;
  bool _busy = false;

  // These let us show success details on-screen (not only in SnackBars).
  String? _selectedGoogleEmail;
  String? _firebaseEmail;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) return;
      setState(() => _pkg = info);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to read package info: $e');
    }
  }

  String _maskedClientId(String id) {
    final trimmed = id.trim();
    if (trimmed.isEmpty) return '(empty)';
    if (trimmed.length <= 10) return trimmed;
    return '…${trimmed.substring(trimmed.length - 10)}';
  }

  Future<void> _continueToGoogleAccountPicker() async {
    setState(() {
      _busy = true;
      _error = null;
      _selectedGoogleEmail = null;
      _firebaseEmail = null;
    });

    try {
      // Initialize with serverClientId so Google will issue an ID token for this client.
      await GoogleSignIn.instance.initialize(
        serverClientId: kServerClientId,
      );

      // Interactive sign-in (account picker).
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: kRequestedScopes,
      );

      final selectedEmail = account.email;

      if (!mounted) return;
      setState(() => _selectedGoogleEmail = selectedEmail);

      // Optional 1-second "success flash" on the same screen.
      // (This is your request: show the selected+firebase info briefly.)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Selected account: $selectedEmail'),
        ),
      );

      // Exchange Google ID token for Firebase session.
      final googleAuth = await account.authentication;

      final idToken = googleAuth.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Google sign-in did not return an ID token. '
          'This typically indicates a Web client ID / SHA mismatch.',
        );
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      final userCred = await FirebaseAuth.instance.signInWithCredential(credential);

      final fbEmail = userCred.user?.email ?? '(no email)';
      if (!mounted) return;

      setState(() => _firebaseEmail = fbEmail);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 1),
          content: Text('Firebase user: $fbEmail'),
        ),
      );

      // Wait 1 second so the user sees the on-screen success info, then navigate.
      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SignedInScreen(
            googleEmail: selectedEmail,
            firebaseEmail: fbEmail,
            firebaseUid: userCred.user?.uid ?? '(no uid)',
          ),
        ),
      );
    } catch (e, st) {
      if (!mounted) return;
      setState(() {
        _error = 'Auth failed:\n$e\n\n$st';
      });
    } finally {
      if (!mounted) return;
      setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pkg = _pkg;

    return Scaffold(
      appBar: AppBar(title: const Text('Auth Preflight')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Auth Inputs (Preflight)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),

            _kv('Package name', pkg?.packageName ?? '(loading)'),
            _kv('Build type', kReleaseMode ? 'release' : 'debug'),

            const SizedBox(height: 8),

            _kv('Requested scopes', kRequestedScopes.join(', ')),
            _kv('Request ID token', 'yes (via serverClientId)'),
            _kv('Request server auth code', 'no (not requested here)'),

            const SizedBox(height: 8),

            _kv('Flow', 'interactive Google Sign-In (account picker)'),
            _kv('serverClientId', _maskedClientId(kServerClientId)),

            // Success info area (shown even when there is no error).
            if (_selectedGoogleEmail != null || _firebaseEmail != null) ...[
              const SizedBox(height: 12),
              const Text(
                'Last run',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              if (_selectedGoogleEmail != null)
                _kv('Selected account', _selectedGoogleEmail!),
              if (_firebaseEmail != null) _kv('Firebase user', _firebaseEmail!),
            ],

            const SizedBox(height: 12),
            if (_error != null) ...[
              const Text('Error', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              SelectableText(_error!),
              const SizedBox(height: 12),
            ],

            FilledButton(
              onPressed: _busy ? null : _continueToGoogleAccountPicker,
              child: Text(_busy ? 'Working…' : 'Okay to continue'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(child: SelectableText(v, style: const TextStyle(height: 1.1))),
        ],
      ),
    );
  }
}

class SignedInScreen extends StatelessWidget {
  final String googleEmail;
  final String firebaseEmail;
  final String firebaseUid;

  const SignedInScreen({
    super.key,
    required this.googleEmail,
    required this.firebaseEmail,
    required this.firebaseUid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Signed in')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'Signed-in state',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _row('Selected account', googleEmail),
            _row('Firebase user', firebaseEmail),
            _row('Firebase UID', firebaseUid),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                try {
                  await GoogleSignIn.instance.disconnect();
                } catch (_) {
                  // Not fatal; disconnect may throw if not connected.
                }
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(k, style: const TextStyle(fontWeight: FontWeight.w600))),
          Expanded(child: SelectableText(v)),
        ],
      ),
    );
  }
}
