import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widget/edit_dialog.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "📚 All Courses"),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("courses").snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No courses found"));
          }

          final courses = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            course["title"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => _onTapDeleteButton(course.id),
                          icon: Icon(Icons.delete, color: Colors.red[200]),
                        ),

                        IconButton(
                          onPressed: () => _onTapEditButton(
                            course.id,
                            course.data() as Map<String, dynamic>,
                          ),
                          icon: const Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    Text(
                      "${course["code"]} • ${course["department"]}",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 10),

                    Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          "${course["credit"]} Credit",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.add),
      ),
    );
  }

  void _onTapDeleteButton(String id) {
    FirebaseFirestore.instance.collection("courses").doc(id).delete();
    trueScaffoldMessage(context, "Deleted Successfully");
  }

  void _addCourse() {
    Navigator.pushNamed(context, '/add-course');
  }

  void _onTapEditButton(String id, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (_) => EditCourseDialog(id: id, data: data),
    );
  }
}
