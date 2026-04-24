import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceRecord {
  final String? id;
  final String courseId;
  final DateTime date;
  final Map<String, String> records; // student id/key -> 'Present' or 'Absent'

  AttendanceRecord({
    this.id,
    required this.courseId,
    required this.date,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'date': Timestamp.fromDate(date),
      'records': records,
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json, String id) {
    final date = (json['date'] as Timestamp?)?.toDate() ?? DateTime.now();
    final records = Map<String, String>.from(
      (json['records'] as Map<String, dynamic>? ?? {})
          .map((key, value) => MapEntry(key, value.toString())),
    );

    return AttendanceRecord(
      id: id,
      courseId: json['courseId'] ?? '',
      date: date,
      records: records,
    );
  }
}

class AttendanceProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, List<AttendanceRecord>> courseAttendance = {};
  Map<String, AttendanceRecord?> todayAttendance = {};
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  void loadCourseAttendance(String courseId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _firestore
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .orderBy('date', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            courseAttendance[courseId] = snapshot.docs.map((doc) {
              return AttendanceRecord.fromJson(doc.data(), doc.id);
            }).toList();

            _isLoading = false;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _isLoading = false;
            _error = error.toString();
            notifyListeners();
          },
        );
  }

  List<AttendanceRecord> getCourseAttendance(String courseId) {
    return courseAttendance[courseId] ?? [];
  }

  Stream<List<AttendanceRecord>> streamCourseAttendance(String courseId) {
    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return AttendanceRecord.fromJson(doc.data(), doc.id);
          }).toList();
        });
  }

  Future<AttendanceRecord?> fetchTodayAttendance(String courseId) async {
    try {
      final normalizedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        todayAttendance[courseId] = null;
        return null;
      }

      final record = AttendanceRecord.fromJson(
        snapshot.docs.first.data(),
        snapshot.docs.first.id,
      );

      todayAttendance[courseId] = record;
      notifyListeners();
      return record;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> isAttendanceSubmittedToday(String courseId) async {
    try {
      final normalizedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> saveAttendance({
    required String courseId,
    required Map<String, String> records,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final normalizedDate = DateTime(
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
      );

      final existing = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        _isLoading = false;
        _error = 'Attendance already submitted for today';
        notifyListeners();
        return false;
      }

      final payload = <String, dynamic>{
        'courseId': courseId,
        'date': Timestamp.fromDate(normalizedDate),
        'records': records,
      };

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .add(payload);

      todayAttendance[courseId] = AttendanceRecord(
        courseId: courseId,
        date: normalizedDate,
        records: records,
      );

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateAttendance({
    required String courseId,
    required String attendanceId,
    required Map<String, String> records,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .doc(attendanceId)
          .update({'records': records});

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteAttendance({
    required String courseId,
    required String attendanceId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .doc(attendanceId)
          .delete();

      if (todayAttendance[courseId]?.id == attendanceId) {
        todayAttendance[courseId] = null;
      }

      _isLoading = false;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  AttendanceRecord? getTodayAttendance(String courseId) {
    return todayAttendance[courseId];
  }

  Stream<AttendanceRecord?> streamTodayAttendance(String courseId) {
    final normalizedDate = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );

    return _firestore
        .collection('courses')
        .doc(courseId)
        .collection('attendance')
        .where('date', isEqualTo: Timestamp.fromDate(normalizedDate))
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return null;
          }
          return AttendanceRecord.fromJson(
            snapshot.docs.first.data(),
            snapshot.docs.first.id,
          );
        });
  }

  Future<Map<String, dynamic>> getAttendanceStats({
    required String courseId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('courses')
          .doc(courseId)
          .collection('attendance')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final records = snapshot.docs
          .map((doc) => AttendanceRecord.fromJson(doc.data(), doc.id))
          .toList();

      final stats = <String, Map<String, int>>{};

      for (final record in records) {
        for (final entry in record.records.entries) {
          final studentId = entry.key;
          final status = entry.value;

          if (!stats.containsKey(studentId)) {
            stats[studentId] = {'present': 0, 'absent': 0, 'total': 0};
          }

          stats[studentId]!['total'] = (stats[studentId]!['total'] ?? 0) + 1;
          if (status == 'Present') {
            stats[studentId]!['present'] =
                (stats[studentId]!['present'] ?? 0) + 1;
          } else {
            stats[studentId]!['absent'] = (stats[studentId]!['absent'] ?? 0) + 1;
          }
        }
      }

      return {
        'totalDays': records.length,
        'studentStats': stats,
      };
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return {};
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clear() {
    courseAttendance.clear();
    todayAttendance.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}

