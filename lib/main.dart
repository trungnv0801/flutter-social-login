import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'dart:io' show Platform;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign In Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SignInPage(),
    );
  }
}

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  String? _name;
  String? _email;
  String? _photoUrl;
  String? _loginMethod;

  Future<void> _signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);
      final account = await googleSignIn.signIn();
      final auth = await account?.authentication;

      setState(() {
        _name = account?.displayName;
        _email = account?.email;
        _photoUrl = account?.photoUrl;
        _loginMethod = "Google";
      });
    } catch (e) {
      print('Google sign-in error: $e');
    }
  }

  Future<void> _signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final userData = await FacebookAuth.instance.getUserData();

        setState(() {
          _name = userData['name'];
          _email = userData['email'];
          _photoUrl = userData['picture']['data']['url'];
          _loginMethod = "Facebook";
        });
      } else {
        print('Facebook sign-in failed: ${result.status}');
      }
    } catch (e) {
      print('Facebook sign-in error: $e');
    }
  }

  Future<void> _signInWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      setState(() {
        _name = "${credential.givenName ?? ""} ${credential.familyName ?? ""}"
            .trim();
        _email = credential.email;
        _photoUrl = null;
        _loginMethod = "Apple";
      });
    } catch (e) {
      print('Apple sign-in error: $e');
    }
  }

  void _signOut() {
    if (_loginMethod == "Google") {
      GoogleSignIn().signOut();
    }
    if (_loginMethod == "Facebook") {
      FacebookAuth.instance.logOut();
    }
    setState(() {
      _name = null;
      _email = null;
      _photoUrl = null;
      _loginMethod = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _email != null;

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In Demo')),
      body: Center(
        child: isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_photoUrl != null)
                    CircleAvatar(
                      backgroundImage: NetworkImage(_photoUrl!),
                      radius: 40,
                    ),
                  const SizedBox(height: 10),
                  Text('Name: $_name'),
                  Text('Email: $_email'),
                  Text('Logged in via: $_loginMethod'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Sign Out'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.g_mobiledata),
                    onPressed: _signInWithGoogle,
                    label: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.facebook),
                    onPressed: _signInWithFacebook,
                    label: const Text('Sign in with Facebook'),
                  ),
                  const SizedBox(height: 12),
                  if (Platform.isIOS)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.apple),
                      onPressed: _signInWithApple,
                      label: const Text('Sign in with Apple'),
                    ),
                ],
              ),
      ),
    );
  }
}
