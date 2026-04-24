import 'package:flutter/material.dart';
import 'package:academix/UI/Widget/main_appbar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "ℹ️ About"),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(height: 20),

            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.blue.shade100,
              child: Icon(Icons.school, size: 55, color: Colors.blue),
            ),

            SizedBox(height: 15),

            Text(
              "Academix",
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 5),

            Text(
              "Course • Student • Routine Manager",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            SizedBox(height: 25),

            _buildSectionTitle("📌 About App"),

            SizedBox(height: 10),

            Text(
              "Academix is a smart academic management app built with Flutter and Firebase. "
              "It helps manage courses, students, and class routines in one place efficiently.",
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.4),
            ),

            SizedBox(height: 25),

            _buildSectionTitle("⚙️ Features"),

            SizedBox(height: 10),

            _feature("Course Management"),
            _feature("Student Enrollment System"),
            _feature("Class Routine Scheduler"),
            _feature("Firebase Integration"),
            _feature("Provider State Management"),

            SizedBox(height: 30),

            _buildSectionTitle("👨‍🏫 Instructor"),

            SizedBox(height: 10),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage(
                        "assets/images/instructor.png",
                      ),
                    ),

                    SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Rayhanul Islam",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Instructor • Mobile App(CSE464)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 30),

            Divider(),

            SizedBox(height: 10),

            Text(
              "Made with ❤️ using Flutter",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _feature(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue, size: 18),
          SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
