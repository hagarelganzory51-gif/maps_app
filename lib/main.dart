import 'package:flutter/material.dart';
import 'package:maps_app/home_screen.dart';

void main() {
  runApp(const MainApp());
}
//key=
//AIzaSyDmFMCSA4aA2n9y1I-HcDpR9kR7WZyb6P4

//AIzaSyCrVKch8-VV5AdTrKhpS6h9Nr_jRwnlHKo

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}
