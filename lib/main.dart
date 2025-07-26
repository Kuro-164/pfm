import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'home_screen.dart';

void main() async {
  // Initialize Flutter and Hive
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Open boxes for storing data
  await Hive.openBox('expenses');
  await Hive.openBox('budget');

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Personal Finance Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );
  }
}