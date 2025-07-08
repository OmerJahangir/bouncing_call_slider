import 'package:bouncing_call_slider/bouncing_call_slider.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bouncing Call Slider Demo',
      debugShowCheckedModeBanner: false,
      home: const CallSliderDemoScreen(),
    );
  }
}

class CallSliderDemoScreen extends StatelessWidget {
  const CallSliderDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F2F2),
      body: Center(
        child: BouncingCallSlider(
          onAccept: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Call Accepted")));
          },
          onDecline: () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Call Declined")));
          },
          acceptText: 'Swipe up to answer',
          declineText: 'Swipe down to decline',
          acceptIcon: const Icon(Icons.call, size: 30, color: Colors.white),
          declineIcon: const Icon(
            Icons.call_end,
            size: 30,
            color: Colors.white,
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          iconColorAccept: Colors.green,
          iconColorDecline: Colors.red,
          callBtnBackgroundColor: Colors.white,
          height: 240,
          width: 80,
          iconSize: 30,
          buttonSize: 80,
        ),
      ),
    );
  }
}
