import 'package:academix/UI/Data/Modals/course_modal.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CourseProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Course> courses = [];

  void loadCourses() {
    _firestore.collection("courses").snapshots().listen((snapshot) {
      courses = snapshot.docs.map((doc) {
        return Course.fromJson(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    });
  }

  Future<void> addCourse(Course course) async {
    await _firestore.collection("courses").add(course.toJson());
  }

  Future<void> updateCourse(Course course) async {
    await _firestore
        .collection("courses")
        .doc(course.id)
        .update(course.toJson());
  }

  Future<void> deleteCourse(String id) async {
    await _firestore.collection("courses").doc(id).delete();
  }
}
