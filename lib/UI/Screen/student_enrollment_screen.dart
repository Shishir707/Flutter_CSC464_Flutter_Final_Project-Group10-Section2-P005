import 'package:academix/UI/Widget/custom_field.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

  void _deleteStudent(String studentId) {
    FirebaseFirestore.instance
        .collection("courses")
        .doc(selectedCourseId)
        .collection("students")
        .doc(studentId)
        .delete();
  }

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
                        child: Text(course["title"]),
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
                controller: _idController,
                label: "Student ID",
                icon: Icons.badge,
              ),

              SizedBox(height: 15),

              CustomTextField(
                controller: _nameController,
                label: "Student Name",
                icon: Icons.person,
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

                          final students = snapshot.data!.docs;

                          if (students.isEmpty) {
                            return Center(child: Text("No students added"));
                          }

                          return ListView.builder(
                            itemCount: students.length,
                            itemBuilder: (context, index) {
                              final student = students[index];

                              return Card(
                                child: ListTile(
                                  title: Text(student["name"]),
                                  subtitle: Text(student["studentId"]),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _deleteStudent(student.id),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.edit,
                                          color: Colors.blue,
                                        ),
                                        onPressed: () => _editStudent(
                                          student.id,
                                          student.data(),
                                        ),
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

      await FirebaseFirestore.instance
          .collection("courses")
          .doc(selectedCourseId)
          .collection("students")
          .add({
            "name": _nameController.text.trim(),
            "studentId": _idController.text.trim(),
            "createdAt": Timestamp.now(),
          });

      if (!mounted) return;

      trueScaffoldMessage(context, "Student added successfully 🎉");
      _clearController();
    } catch (e) {
      falseScaffoldMessage(context, e.toString());
    }
  }

  void _editStudent(String id, Object? data) {}

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
