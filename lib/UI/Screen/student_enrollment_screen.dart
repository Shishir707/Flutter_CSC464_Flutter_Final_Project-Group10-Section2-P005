import 'package:academix/UI/Widget/custom_field.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "‍🎓 Student Enrollment"),

      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("courses")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  final courses = snapshot.data!.docs;

                  return DropdownButtonFormField<String>(
                    hint: Text("Select Course"),
                    initialValue: selectedCourseId,
                    items: courses.map((course) {
                      return DropdownMenuItem(
                        value: course.id,
                        child: Text(course["name"]),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCourseId = value;
                      });
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

              SizedBox(height: 20),

              Expanded(
                child: selectedCourseId == null
                    ? Center(child: Text("Select a course first"))
                    : StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("courses")
                            .doc(selectedCourseId)
                            .collection("students")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          }

                          final students = snapshot.data!.docs
                              .map(
                                (doc) => Student.fromJson(
                                  doc.data() as Map<String, dynamic>,
                                  doc.id,
                                ),
                              )
                              .toList();

                          if (students.isEmpty) {
                            return Center(child: Text("No students added"));
                          }

                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];

                              return Card(
                                child: ListTile(
                                  title: Text(student.name),
                                  subtitle: Text(student.studentId),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteStudent(student),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editStudent(student),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
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

    try {
      final existing = await FirebaseFirestore.instance
          .collection("courses")
          .doc(selectedCourseId)
          .collection("students")
          .where("studentId", isEqualTo: _idController.text.trim())
          .get();

      if (!mounted) return;

      if (existing.docs.isNotEmpty) {
        falseScaffoldMessage(context, "Student already exists");
        return;
      }

      final student = Student(
        name: _nameController.text.trim(),
        studentId: _idController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection("courses")
          .doc(selectedCourseId)
          .collection("students")
          .add(student.toJson());

      if (!mounted) return;

      trueScaffoldMessage(context, "Student added successfully 🎉");
      _clearController();
    } catch (e) {
      falseScaffoldMessage(context, e.toString());
    }
  }

  void _editStudent(Student student) {}

  void _deleteStudent(Student student) {
    FirebaseFirestore.instance
        .collection("courses")
        .doc(selectedCourseId)
        .collection("students")
        .doc(student.id!)
        .delete();
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
