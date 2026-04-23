import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Data/Modals/student_model.dart';

class StudentListScreen extends StatelessWidget {
  const StudentListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "🎓 All Students"),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("courses").snapshots(),
        builder: (context, courseSnapshot) {
          if (!courseSnapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final courses = courseSnapshot.data!.docs;

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("courses")
                    .doc(course.id)
                    .collection("students")
                    .snapshots(),
                builder: (context, studentSnapshot) {
                  if (!studentSnapshot.hasData) {
                    return SizedBox();
                  }

                  final students = studentSnapshot.data!.docs
                      .map(
                        (doc) => Student.fromJson(
                          doc.data() as Map<String, dynamic>,
                          doc.id,
                        ),
                      )
                      .toList();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          "📚 ${course['name']} (${course['code']})",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      ...students.map((student) {
                        return Card(
                          margin: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          child: ListTile(
                            leading: Icon(Icons.person),
                            title: Text(student.name),
                            subtitle: Text("ID: ${student.studentId}"),

                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _editStudent(student),
                                ),

                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _deleteStudent(student),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _editStudent(Student student) {}

  void _deleteStudent(Student student) {}
}
