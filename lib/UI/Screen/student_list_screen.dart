import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/course_provider.dart';
import '../../Provider/student_provider.dart';
import '../Data/Modals/student_model.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "🎓 All Students"),

      body: Consumer<CourseProvider>(
        builder: (context, courseProvider, child) {
          final courses = courseProvider.courses;

          if (courses.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];

              Provider.of<StudentProvider>(
                context,
                listen: false,
              ).loadStudents(course.id!);

              return Consumer<StudentProvider>(
                builder: (context, studentProvider, child) {
                  final students = studentProvider.getStudents(course.id!);

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
                          "📚 ${course.name} (${course.code})",
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
                                  onPressed: () => _deleteStudent(
                                    context,
                                    student,
                                    course.id!,
                                  ),
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

  void _deleteStudent(BuildContext context, Student student, String courseId) {
    Provider.of<StudentProvider>(
      context,
      listen: false,
    ).deleteStudent(courseId: courseId, studentId: student.id!);
  }
}
