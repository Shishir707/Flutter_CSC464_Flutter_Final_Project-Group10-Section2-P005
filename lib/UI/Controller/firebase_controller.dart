import 'package:cloud_firestore/cloud_firestore.dart';

class AcademixController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getCourses() async {
    final snapshot = await _firestore.collection("courses").get();

    return snapshot.docs.map((doc) {
      return {"id": doc.id, ...doc.data()};
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getStudents(String courseId) async {
    final snapshot = await _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .get();

    return snapshot.docs.map((doc) {
      return {"id": doc.id, ...doc.data()};
    }).toList();
  }

  Stream<List<Map<String, dynamic>>> streamCourses() {
    return _firestore.collection("courses").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> streamStudents(String courseId) {
    return _firestore
        .collection("courses")
        .doc(courseId)
        .collection("students")
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return {"id": doc.id, ...doc.data()};
          }).toList();
        });
  }
}
