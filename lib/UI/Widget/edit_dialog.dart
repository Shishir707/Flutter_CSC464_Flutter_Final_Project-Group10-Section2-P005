import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Data/Models/course_model.dart';

class EditCourseDialog extends StatefulWidget {
  final Course course;

  const EditCourseDialog({super.key, required this.course});

  @override
  State<EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.course.name);
    _codeController = TextEditingController(text: widget.course.code);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("✏️ Edit Course"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _field(_nameController, "Course Name"),
            SizedBox(height: 10),
            _field(_codeController, "Course Code"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateCourse,
          child: _isLoading
              ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text("Update"),
        ),
      ],
    );
  }

  Widget _field(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  Future<void> _updateCourse() async {
    final name = _nameController.text.trim();
    final code = _codeController.text.trim();

    if (name.isEmpty || code.isEmpty) {
      trueScaffoldMessage(context, "Fields cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("courses")
          .doc(widget.course.id)
          .update({"name": name, "code": code});

      if (mounted) {
        Navigator.pop(context);
        trueScaffoldMessage(context, "Updated Successfully!");
      }
    } catch (e) {
      trueScaffoldMessage(context, "Update failed");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }
}
