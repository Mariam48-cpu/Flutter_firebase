import 'package:ecommerce_app_api_26/features/auth/presentation/screens/login_screen.dart';
import 'package:ecommerce_app_api_26/features/auth/presentation/screens/signup_screen.dart';
import 'package:ecommerce_app_api_26/features/home/presentation/screens/home_screen.dart';
import 'package:ecommerce_app_api_26/features/main_wrapper/presentation/screens/main_wrapper.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:ecommerce_app_api_26/utils/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const MainWrapper(),
    );
  }
}
