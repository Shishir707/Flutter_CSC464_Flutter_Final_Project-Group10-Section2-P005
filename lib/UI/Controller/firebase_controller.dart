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

  Stream<List<Map<String, dynamic>>> streamRoutine() {
    return _firestore.collection("routine").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return {"id": doc.id, ...doc.data()};
      }).toList();
    });
  }

  Future<bool> isRoutineExists({
    required String courseId,
    required String day,
    required String time,
  }) async {
    final res = await _firestore
        .collection("routine")
        .where("courseId", isEqualTo: courseId)
        .where("day", isEqualTo: day)
        .where("time", isEqualTo: time)
        .get();

    return res.docs.isNotEmpty;
  }

  Future<void> addRoutine({
    required String courseId,
    required String day,
    required String time,
  }) async {
    await _firestore.collection("routine").add({
      "courseId": courseId,
      "day": day,
      "time": time,
      "createdAt": Timestamp.now(),
    });
  }
}
