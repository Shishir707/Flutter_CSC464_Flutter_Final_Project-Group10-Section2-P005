import 'package:academix/UI/Screen/home_screen.dart';
import 'package:academix/UI/Screen/sign_in_screen.dart';
import 'package:academix/UI/Screen/sign_up_screen.dart';
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
        '/home': (_) => HomeScreen(),
        '/sign-in': (_) => SignInScreen(),
        '/sign-up': (_) => SignUpScreen(),
      },

      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),

        scaffoldBackgroundColor: Colors.blue.shade50,

        appBarTheme: AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.black,
          elevation: 0,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          hintStyle: TextStyle(color: Colors.grey),

          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.blue, width: 2),
          ),
        ),

        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.black,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade200,
            foregroundColor: Colors.black,
            elevation: 0,
            padding: EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),

        textTheme: TextTheme(
          titleLarge: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          labelMedium: TextStyle(fontSize: 15, color: Colors.black54),
        ),
      ),
    );
  }
}
