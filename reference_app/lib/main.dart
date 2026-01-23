// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'auth_preflight_screen.dart';
import 'startup_gate_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase must be initialized before any FirebaseAuth usage.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ReferenceApp());
}

class ReferenceApp extends StatelessWidget {
  const ReferenceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Toolchain Reference App',
      theme: ThemeData(useMaterial3: true),
      home: const StartupGateScreen(),
    );
  }
}

// class HomeScreen extends StatelessWidget {
//   const HomeScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Reference App')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             Navigator.of(context).push(
//               MaterialPageRoute(builder: (_) => const AuthPreflightScreen()),
//             );
//           },
//           child: const Text('Sign in with Google'),
//         ),
//       ),
//     );
//   }
// }



// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// import 'firebase_options.dart';

// /// IMPORTANT:
// /// This is the *OAuth Client ID* with `client_type: 3` from google-services.json
// /// (the “Web client” / “server client id”).
// ///
// /// In your posted google-services.json, that is:
// /// 883224591051-apnl4fdr2on5ar1d1pbhfk2fpoi0ldle.apps.googleusercontent.com
// const String kServerClientId =
//     '883224591051-apnl4fdr2on5ar1d1pbhfk2fpoi0ldle.apps.googleusercontent.com';

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Toolchain Ref App',
//       theme: ThemeData(useMaterial3: true),
//       home: const AuthGate(),
//     );
//   }
// }

// class AuthGate extends StatefulWidget {
//   const AuthGate({super.key});

//   @override
//   State<AuthGate> createState() => _AuthGateState();
// }

// class _AuthGateState extends State<AuthGate> {
//   StreamSubscription<GoogleSignInAuthenticationEvent>? _sub;

//   GoogleSignInAccount? _googleUser;
//   bool _busy = true;
//   String? _error;

//   @override
//   void initState() {
//     super.initState();
//     _initGoogleSignIn();
//   }

//   Future<void> _initGoogleSignIn() async {
//     setState(() {
//       _busy = true;
//       _error = null;
//     });

//     try {
//       final GoogleSignIn signIn = GoogleSignIn.instance;

//       // google_sign_in 7.x requires initialize() + authenticationEvents.
//       await signIn.initialize(serverClientId: kServerClientId);

//       _sub = signIn.authenticationEvents
//           .listen(_handleGoogleAuthEvent, onError: _handleGoogleAuthError);

//       // Optional: attempts a "silent" / lightweight auth if possible.
//       await signIn.attemptLightweightAuthentication();
//     } catch (e) {
//       _error = 'GoogleSignIn init failed: $e';
//     } finally {
//       if (mounted) {
//         setState(() => _busy = false);
//       }
//     }
//   }

//   Future<void> _handleGoogleAuthEvent(
//     GoogleSignInAuthenticationEvent event,
//   ) async {
//     final GoogleSignInAccount? user = switch (event) {
//       GoogleSignInAuthenticationEventSignIn() => event.user,
//       GoogleSignInAuthenticationEventSignOut() => null,
//     };

//     setState(() {
//       _googleUser = user;
//       _error = null;
//     });

//     // Keep FirebaseAuth in sync with Google sign-in state.
//     if (user == null) {
//       await FirebaseAuth.instance.signOut();
//       return;
//     }

//     try {
//       final googleAuth = await user.authentication;
//       final idToken = googleAuth.idToken;

//       if (idToken == null || idToken.isEmpty) {
//         throw Exception(
//           'Google sign-in did not return an ID token. '
//           'This usually indicates an OAuth/SHA-1/google-services.json mismatch.',
//         );
//       }

//       final credential = GoogleAuthProvider.credential(idToken: idToken);

//       await FirebaseAuth.instance.signInWithCredential(credential);
//     } catch (e) {
//       setState(() {
//         _error = 'Firebase sign-in failed: $e';
//       });
//     }
//   }

//   void _handleGoogleAuthError(Object e) {
//     setState(() {
//       _googleUser = null;
//       _error = e.toString();
//     });
//   }

//   Future<void> _startInteractiveGoogleSignIn() async {
//     setState(() {
//       _busy = true;
//       _error = null;
//     });

//     try {
//       // In google_sign_in 7.x, this is the interactive sign-in entry point.
//       await GoogleSignIn.instance.authenticate();
//       // The result arrives via authenticationEvents.
//     } catch (e) {
//       setState(() {
//         _error = 'Google authenticate() failed: $e';
//       });
//     } finally {
//       if (mounted) setState(() => _busy = false);
//     }
//   }

//   Future<void> _signOutEverywhere() async {
//     setState(() {
//       _busy = true;
//       _error = null;
//     });

//     try {
//       await FirebaseAuth.instance.signOut();
//       // Disconnect is recommended in the google_sign_in example to reset state.
//       await GoogleSignIn.instance.disconnect();
//       // Sign-out event will also arrive via authenticationEvents.
//     } catch (e) {
//       setState(() {
//         _error = 'Sign out failed: $e';
//       });
//     } finally {
//       if (mounted) setState(() => _busy = false);
//     }
//   }

//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (_busy) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     final firebaseUser = FirebaseAuth.instance.currentUser;

//     if (firebaseUser == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Toolchain Ref App')),
//         body: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 420),
//               child: Column(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   ElevatedButton(
//                     onPressed: _startInteractiveGoogleSignIn,
//                     child: const Text('Sign in with Google'),
//                   ),
//                   if (_error != null) ...[
//                     const SizedBox(height: 16),
//                     Text(
//                       _error!,
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.red),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(title: const Text('Signed in')),
//       body: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxWidth: 520),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text('Google user: ${_googleUser?.email ?? "(unknown)"}'),
//               const SizedBox(height: 16),
//               Text('Firebase UID: ${firebaseUser.uid}'),
//               const SizedBox(height: 8),
//               Text('Firebase email: ${firebaseUser.email ?? "(none)"}'),
//               const SizedBox(height: 8),
//               Text('Display name: ${firebaseUser.displayName ?? "(none)"}'),
//               const SizedBox(height: 24),
//               ElevatedButton(
//                 onPressed: _signOutEverywhere,
//                 child: const Text('Sign out'),
//               ),
//               if (_error != null) ...[
//                 const SizedBox(height: 16),
//                 Text(
//                   _error!,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red),
//                 ),
//               ],
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
