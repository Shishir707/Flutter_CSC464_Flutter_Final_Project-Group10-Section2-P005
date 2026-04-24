import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/course_provider.dart';
import '../../Provider/student_provider.dart';
import '../Data/Modals/course_modal.dart';
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
      final courseProvider = Provider.of<CourseProvider>(
        context,
        listen: false,
      );
      final studentProvider = Provider.of<StudentProvider>(
        context,
        listen: false,
      );

      courseProvider.loadCourses();

      for (var course in courseProvider.courses) {
        studentProvider.loadStudents(course.id!);
      }
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
                                  onPressed: () =>
                                      _editStudent(student, course),
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

  void _deleteStudent(BuildContext context, Student student, String courseId) {
    Provider.of<StudentProvider>(
      context,
      listen: false,
    ).deleteStudent(courseId: courseId, studentId: student.id!);
  }

  void _editStudent(Student student, Course course) {
    final nameController = TextEditingController(text: student.name);
    final idController = TextEditingController(text: student.studentId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Student"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: idController,
                decoration: InputDecoration(labelText: "Student ID"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () async {
                final updatedStudent = Student(
                  id: student.id,
                  name: nameController.text.trim(),
                  studentId: idController.text.trim(),
                );

                await Provider.of<StudentProvider>(
                  context,
                  listen: false,
                ).editStudent(courseId: course.id!, student: updatedStudent);

                trueScaffoldMessage(context, "Updated student info");

                Navigator.pop(context);
              },
              child: Text("Update"),
            ),
          ],
        );
      },
    );
  }
}
