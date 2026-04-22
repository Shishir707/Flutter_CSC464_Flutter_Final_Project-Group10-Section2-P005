import 'package:academix/UI/Screen/home_screen.dart';
import 'package:flutter/material.dart';

import 'UI/Screen/splash_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Academix",
      debugShowCheckedModeBanner: false,

      initialRoute: '/',

      routes: <String, WidgetBuilder>{
        '/': (_) => SplashScreen(),
        'home': (_) => HomeScreen(),
      },
    );
  }
}
