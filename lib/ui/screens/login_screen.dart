import 'dart:developer';

import 'package:chat_box/api/apis.dart';
import 'package:chat_box/ui/screens/home_screen.dart';
import 'package:chat_box/helper/snack_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  _handleGoogleLoginButton() {
    Dialogs.showProgressBar(context);

    _signInWithGoogle().then(
      (user) async {
        Navigator.pop(context);
        if (user != null) {
          log('User: ${user.user}');
          log('User Additional info: ${user.additionalUserInfo}');

          if ((await APIs.userExists())) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (contex) => HomePage(),
              ),
            );
          } else {
            await APIs.createUser().then((value) {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const HomePage()));
            });
          }
        }
      },
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await APIs.auth.signInWithCredential(credential);
    } catch (e) {
      log(e.toString());
      if (mounted) {
        Dialogs.showMessage(context, 'Something went wrong!(Check Internet)');
      }
      setState(() {});
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to Chat Box'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: SizedBox(
              width: 120,
              height: 120,
              child: Image.asset('assets/icons/icon.png'),
            ),
          ),
          const SizedBox(
            height: 200,
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 50),
              child: ElevatedButton.icon(
                onPressed: () {
                  _handleGoogleLoginButton();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey.shade100,
                    shape: const StadiumBorder(),
                    elevation: 1),
                icon: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Image.asset(
                    'assets/images/google.png',
                    height: 40,
                    width: 40,
                  ),
                ),
                label: RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.black),
                    children: [
                      TextSpan(text: 'Sign in with'),
                      TextSpan(
                        text: ' Google',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
