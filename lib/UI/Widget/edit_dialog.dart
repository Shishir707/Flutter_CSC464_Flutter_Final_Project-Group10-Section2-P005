import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditCourseDialog extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const EditCourseDialog({super.key, required this.id, required this.data});

  @override
  State<EditCourseDialog> createState() => _EditCourseDialogState();
}

class _EditCourseDialogState extends State<EditCourseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _codeController;
  late TextEditingController _creditController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();

    _titleController = TextEditingController(text: widget.data["title"]);
    _codeController = TextEditingController(text: widget.data["code"]);
    _creditController = TextEditingController(
      text: widget.data["credit"].toString(),
    );
    _departmentController = TextEditingController(
      text: widget.data["department"],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("✏️ Edit Course"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            _field(_titleController, "Title"),
            SizedBox(height: 10),
            _field(_codeController, "Code"),
            SizedBox(height: 10),
            _field(_creditController, "Credit", number: true),
            SizedBox(height: 10),
            _field(_departmentController, "Department"),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
        ElevatedButton(onPressed: _updateCourse, child: Text("Update")),
      ],
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool number = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: number ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _updateCourse() async {
    await FirebaseFirestore.instance
        .collection("courses")
        .doc(widget.id)
        .update({
          "title": _titleController.text.trim(),
          "code": _codeController.text.trim(),
          "credit": double.tryParse(_creditController.text.trim()) ?? 0,
          "department": _departmentController.text.trim(),
        });

    trueScaffoldMessage(context, "Updated Successfully!");

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _codeController.dispose();
    _departmentController.dispose();
    _creditController.dispose();

    super.dispose();
  }
}
