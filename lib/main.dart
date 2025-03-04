import 'package:flutter/material.dart';
import 'package:news_app/screens/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main ()async{
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }

}