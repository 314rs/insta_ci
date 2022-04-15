import 'package:flutter/material.dart';
import 'edit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insta CI',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const Edit(),
    );
  }
}
