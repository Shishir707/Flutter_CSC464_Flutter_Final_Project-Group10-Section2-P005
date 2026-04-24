import 'package:academix/Provider/routine_provider.dart';
import 'package:academix/Provider/student_provider.dart';
import 'package:academix/UI/Screen/home_screen.dart';
import 'package:academix/UI/Screen/sign_in_screen.dart';
import 'package:academix/UI/Screen/sign_up_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Provider/course_provider.dart';
import 'UI/Screen/add_course.dart';
import 'UI/Screen/attendance_screen.dart';
import 'UI/Screen/attendance_summary_screen.dart';
import 'UI/Screen/course_screen.dart';
import 'UI/Screen/routine_screen.dart';
import 'UI/Screen/splash_screen.dart';
import 'UI/Screen/student_enrollment_screen.dart';
import 'UI/Screen/student_list_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CourseProvider()),
        ChangeNotifierProvider(create: (context) => StudentProvider()),
        ChangeNotifierProvider(create: (context) => RoutineProvider()),
      ],
      child: MaterialApp(
        title: "Academix",
        debugShowCheckedModeBanner: false,

        initialRoute: '/',

        routes: <String, WidgetBuilder>{
          '/': (_) => SplashScreen(),
          '/home': (_) => HomeScreen(),
          '/sign-in': (_) => SignInScreen(),
          '/sign-up': (_) => SignUpScreen(),
          '/course': (_) => CourseScreen(),
          '/add-course': (_) => AddCourseScreen(),
          '/student-enrollment': (_) => StudentEnrollmentScreen(),
          '/student-list': (_) => StudentListScreen(),
          '/routine': (_) => RoutineScreen(),
          '/attendance': (_) => AttendanceScreen(),
          '/summary': (_) => AttendanceSummaryScreen(),
        },

        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue.shade50),

          scaffoldBackgroundColor: Colors.blue.shade50,

          appBarTheme: AppBarTheme(
            backgroundColor: Colors.blue.shade200,
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
      ),
    );
  }
}
