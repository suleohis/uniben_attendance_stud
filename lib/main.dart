import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'home/homepage.dart';

void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Student Attendance Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home:   AnimatedSplashScreen(
            duration: 3000,
            splash: Image.asset('assets/app_logo.png',width: 150,height: 150,),
            nextScreen:  HomePage(null),
            splashTransition: SplashTransition.fadeTransition,
            backgroundColor: Colors.white));


  }
}