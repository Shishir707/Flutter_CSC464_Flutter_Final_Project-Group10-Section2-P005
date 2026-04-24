import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../UI/Data/Modals/student_model.dart';

class StudentProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<Student>> courseStudents = {};

  void loadStudents(String courseId) {
    _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .snapshots()
        .listen((snapshot) {
          courseStudents[courseId] = snapshot.docs.map((doc) {
            return Student.fromJson(doc.data(), doc.id);
          }).toList();

          notifyListeners();
        });
  }

  List<Student> getStudents(String courseId) {
    return courseStudents[courseId] ?? [];
  }

  Future<String?> addStudent({
    required String courseId,
    required Student student,
  }) async {
    final existing = await _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .where("studentId", isEqualTo: student.studentId)
        .get();

    if (existing.docs.isNotEmpty) {
      return "Student already exists";
    }

    await _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .add(student.toJson());

    return null;
  }

  Future<void> deleteStudent({
    required String courseId,
    required String studentId,
  }) async {
    await _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .doc(studentId)
        .delete();
  }
}
