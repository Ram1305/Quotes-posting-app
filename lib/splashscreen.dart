import 'package:flutter/material.dart';
import 'package:kavithaiquote/kavithai.dart';
import 'package:kavithaiquote/login.dart';
import 'package:kavithaiquote/signupscreen.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Future<void> loadData() async {
      await Future.delayed(const Duration(seconds: 3));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) {
          return isLoggedIn ? ProfileScreen() : LoginScreen();
        }),
      );
    }

    loadData();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Center(
              child: Lottie.asset(
                "assets/kavithai.json",
                fit: BoxFit.fill,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 75.0),
            child: const Center(
              child: Text(
                "கவிதைகள்", // Using constant
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
