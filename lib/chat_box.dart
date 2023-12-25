import 'package:chat_box/ui/screens/splash_screen.dart';
import 'package:flutter/material.dart';

class ChatBox extends StatelessWidget {
  const ChatBox({super.key});



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          elevation: 1,
          backgroundColor: Colors.white,
        ),
        primaryColor: Colors.blue,
        useMaterial3: false,
      ),
    );
  }
}
