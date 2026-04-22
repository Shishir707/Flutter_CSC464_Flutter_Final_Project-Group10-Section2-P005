import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../Widget/custom_field.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _creditController = TextEditingController();
  final TextEditingController _departmentController = TextEditingController();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "➕ Add Course"),

      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                label: "Course Title",
                icon: Icons.book,
              ),
              SizedBox(height: 12),

              CustomTextField(
                controller: _codeController,
                label: "Course Code",
                icon: Icons.code,
              ),
              SizedBox(height: 12),

              CustomTextField(
                controller: _creditController,
                label: "Credit (e.g 3.0)",
                icon: Icons.star,
              ),
              SizedBox(height: 12),

              CustomTextField(
                controller: _departmentController,
                label: "Department",
                icon: Icons.apartment,
              ),

              SizedBox(height: 25),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _addCourse,
                  child: _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("Add Course"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addCourse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection("courses").add({
        "title": _titleController.text.trim(),
        "code": _codeController.text.trim(),
        "credit": double.parse(_creditController.text.trim()),
        "department": _departmentController.text.trim(),
        "createdAt": Timestamp.now(),
      });

      if (!mounted) return;

      trueScaffoldMessage(context, 'Course added successfully 🎉');

      _clearController();

      Navigator.pop(context);
    } catch (e) {
      falseScaffoldMessage(context, e.toString());
    }

    setState(() => _isLoading = false);
  }

  void _clearController() {
    _departmentController.clear();
    _creditController.clear();
    _codeController.clear();
    _titleController.clear();
  }

  @override
  void dispose() {
    _departmentController.dispose();
    _creditController.dispose();
    _codeController.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
