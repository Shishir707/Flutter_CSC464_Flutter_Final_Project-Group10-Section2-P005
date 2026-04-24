import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/course_provider.dart';
import '../Data/Modals/course_modal.dart';
import '../Widget/custom_field.dart';

class AddCourseScreen extends StatefulWidget {
  const AddCourseScreen({super.key});

  @override
  State<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends State<AddCourseScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();

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
                controller: _nameController,
                label: "Course Title",
                icon: Icons.book,
              ),
              SizedBox(height: 12),

              CustomTextField(
                controller: _codeController,
                label: "Course Code",
                icon: Icons.code,
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
      final course = Course(
        name: _nameController.text.trim(),
        code: _codeController.text.trim(),
      );

      await Provider.of<CourseProvider>(
        context,
        listen: false,
      ).addCourse(course);

      if (!mounted) return;

      trueScaffoldMessage(context, 'Course added successfully 🎉');

      _clearController();
      Navigator.pop(context);
    } catch (e) {
      falseScaffoldMessage(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _clearController() {
    _codeController.clear();
    _nameController.clear();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
