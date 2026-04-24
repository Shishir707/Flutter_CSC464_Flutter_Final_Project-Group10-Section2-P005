import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../UI/Data/Modals/routine_model.dart';

class RoutineProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Routine> routines = [];

  void loadRoutines() {
    _firestore.collection("routine").snapshots().listen((snapshot) {
      routines = snapshot.docs.map((doc) {
        return Routine.fromJson(doc.data(), doc.id);
      }).toList();

      notifyListeners();
    });
  }

  Future<String?> addRoutine(Routine routine) async {
    final existing = await _firestore
        .collection("routine")
        .where("courseId", isEqualTo: routine.courseId)
        .where("day", isEqualTo: routine.day)
        .where("time", isEqualTo: routine.time)
        .get();

    if (existing.docs.isNotEmpty) {
      return "Routine already exists ❌";
    }

    await _firestore.collection("routine").add(routine.toJson());

    return null;
  }
}
