import 'package:flutter/material.dart';
import 'package:url_shortener_mobile/screens/form.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'URL Shortener',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FormScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
