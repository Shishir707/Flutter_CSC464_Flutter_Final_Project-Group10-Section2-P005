import 'package:academix/UI/Widget/custom_field.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/course_provider.dart';
import '../../Provider/student_provider.dart';
import '../Data/Modals/student_model.dart';

class StudentEnrollmentScreen extends StatefulWidget {
  const StudentEnrollmentScreen({super.key});

  @override
  State<StudentEnrollmentScreen> createState() =>
      _StudentEnrollmentScreenState();
}

class _StudentEnrollmentScreenState extends State<StudentEnrollmentScreen> {
  String? selectedCourseId;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

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
      appBar: mainAppBar(context, "🎓 Student Enrollment"),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Consumer<CourseProvider>(
                builder: (context, provider, child) {
                  final courses = provider.courses;

                  if (courses.isEmpty) {
                    return Center(child: CircularProgressIndicator());
                  }

                  return DropdownButtonFormField<String>(
                    hint: Text("Select Course"),
                    initialValue: selectedCourseId,
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course.name),
                      );
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCourseId = value;
                      });

                      if (value != null) {
                        Provider.of<StudentProvider>(
                          context,
                          listen: false,
                        ).loadStudents(value);
                      }
                    },
                  );
                },
              ),

              SizedBox(height: 15),

              CustomTextField(
                controller: _nameController,
                label: "Student Name",
                icon: Icons.person,
              ),

              SizedBox(height: 15),

              CustomTextField(
                controller: _idController,
                label: "Student ID",
                icon: Icons.badge,
              ),

              SizedBox(height: 15),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onTapAddStudent,
                  child: Text(
                    "Add Student",
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _onTapStudentList,
        backgroundColor: Colors.blue,
        child: Icon(Icons.list),
      ),
    );
  }

  Future<void> _onTapAddStudent() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedCourseId == null) {
      falseScaffoldMessage(context, "Select a course first");
      return;
    }

    final student = Student(
      name: _nameController.text.trim(),
      studentId: _idController.text.trim(),
    );

    final error = await Provider.of<StudentProvider>(
      context,
      listen: false,
    ).addStudent(courseId: selectedCourseId!, student: student);

    if (!mounted) return;

    if (error != null) {
      falseScaffoldMessage(context, error);
      return;
    }

    trueScaffoldMessage(context, "Student added successfully 🎉");
    _clearController();
  }

  void _clearController() {
    _nameController.clear();
    _idController.clear();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _onTapStudentList() {
    Navigator.pushNamed(context, '/student-list');
  }
}
