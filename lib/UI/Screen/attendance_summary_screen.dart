import 'package:academix/UI/Controller/firebase_controller.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceSummaryScreen extends StatefulWidget {
  const AttendanceSummaryScreen({super.key});

  @override
  State<AttendanceSummaryScreen> createState() => _AttendanceSummaryScreenState();
}

class _AttendanceSummaryScreenState extends State<AttendanceSummaryScreen> {
  final AcademixController _controller = AcademixController();
  String? _selectedCourseId;
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, 'Attendance Summary'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCourseSelector(),
            const SizedBox(height: 10),
            _buildSearchBox(),
            const SizedBox(height: 10),
            Expanded(
              child: _selectedCourseId == null
                  ? _buildEmptyState('Select a course to view summary')
                  : _buildSummary(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseSelector() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _controller.streamCourses(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LinearProgressIndicator();
        }

        final courses = snapshot.data ?? <Map<String, dynamic>>[];

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: _selectedCourseId,
            decoration: const InputDecoration(
              labelText: 'Course',
              prefixIcon: Icon(Icons.menu_book_rounded),
            ),
            hint: const Text('Select Course'),
            items: courses
                .map(
                  (course) => DropdownMenuItem<String>(
                    value: course['id']?.toString(),
                    child: Text(
                      '${course['title'] ?? ''} (${course['code'] ?? ''})',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCourseId = value;
                _searchText = '';
              });
            },
          ),
        );
      },
    );
  }

  Widget _buildSearchBox() {
    return TextField(
      onChanged: (value) {
        setState(() {
          _searchText = value.trim().toLowerCase();
        });
      },
      decoration: const InputDecoration(
        hintText: 'Search by name or student ID',
        prefixIcon: Icon(Icons.search),
      ),
    );
  }

  Widget _buildSummary() {
    final studentsStream = _controller.streamStudents(_selectedCourseId!);
    final attendanceStream = FirebaseFirestore.instance
        .collection('courses')
        .doc(_selectedCourseId)
        .collection('attendance')
        .orderBy('date')
        .snapshots();

    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: studentsStream,
      builder: (context, studentSnapshot) {
        if (studentSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = studentSnapshot.data ?? <Map<String, dynamic>>[];

        if (students.isEmpty) {
          return _buildEmptyState('No students enrolled in this course');
        }

        final filteredStudents = students.where((student) {
          if (_searchText.isEmpty) {
            return true;
          }
          final name = (student['name']?.toString() ?? '').toLowerCase();
          final studentId = (student['studentId']?.toString() ?? '').toLowerCase();
          return name.contains(_searchText) || studentId.contains(_searchText);
        }).toList();

        if (filteredStudents.isEmpty) {
          return _buildEmptyState('No student found for search');
        }

        return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: attendanceStream,
          builder: (context, attendanceSnapshot) {
            if (attendanceSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final attendanceDocs = attendanceSnapshot.data?.docs ??
                <QueryDocumentSnapshot<Map<String, dynamic>>>[];

            final sessions = attendanceDocs
                .map((doc) {
                  final data = doc.data();
                  return {
                    'date': data['date'],
                    'records': Map<String, dynamic>.from(
                      data['records'] as Map<String, dynamic>? ?? <String, dynamic>{},
                    ),
                  };
                })
                .toList();

            final totalClasses = sessions.length;
            final presentMap = <String, int>{};

            for (final student in filteredStudents) {
              final id = student['id']?.toString() ?? '';
              presentMap[id] = 0;
            }

            for (final session in sessions) {
              final records = session['records'] as Map<String, dynamic>;
              for (final entry in records.entries) {
                if (entry.value == 'Present' && presentMap.containsKey(entry.key)) {
                  presentMap[entry.key] = (presentMap[entry.key] ?? 0) + 1;
                }
              }
            }

            final presentAll = presentMap.values.fold<int>(0, (a, b) => a + b);
            final totalCell = totalClasses * filteredStudents.length;
            final overall = totalCell == 0 ? 0.0 : (presentAll / totalCell) * 100;

            return Column(
              children: [
                _buildTopStats(totalClasses, filteredStudents.length, overall),
                const SizedBox(height: 10),
                Expanded(
                  child: _buildAttendanceSheet(
                    students: filteredStudents,
                    sessions: sessions,
                    presentMap: presentMap,
                    totalClasses: totalClasses,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTopStats(int totalClasses, int totalStudents, double overall) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          _tag('Classes', '$totalClasses', Colors.indigo),
          const SizedBox(width: 8),
          _tag('Students', '$totalStudents', Colors.blue),
          const SizedBox(width: 8),
          _tag('Overall', '${overall.toStringAsFixed(1)}%', Colors.green),
        ],
      ),
    );
  }

  Widget _buildAttendanceSheet({
    required List<Map<String, dynamic>> students,
    required List<Map<String, dynamic>> sessions,
    required Map<String, int> presentMap,
    required int totalClasses,
  }) {
    final headers = <String>['SL', 'ID', 'Name'];
    headers.addAll(List<String>.generate(sessions.length, (i) => 'C${i + 1}'));
    headers.addAll(<String>['Att', 'Att %']);

    final sheetWidth = (headers.length * 72).toDouble() + 120;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: sheetWidth,
          child: Column(
            children: [
              _buildHeaderRow(headers),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => Divider(
                    height: 1,
                    color: Colors.blue.shade50,
                  ),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final studentKey = student['id']?.toString() ?? '';
                    final attended = presentMap[studentKey] ?? 0;
                    final percentage =
                        totalClasses == 0 ? 0.0 : (attended / totalClasses) * 100;

                    return _buildDataRow(
                      sl: index + 1,
                      student: student,
                      sessions: sessions,
                      studentKey: studentKey,
                      attended: attended,
                      percentage: percentage,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(List<String> headers) {
    return Container(
      color: Colors.blue.shade50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: headers.map((h) {
          return _cell(
            h,
            width: _columnWidth(h),
            isHeader: true,
            alignLeft: h == 'Name',
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDataRow({
    required int sl,
    required Map<String, dynamic> student,
    required List<Map<String, dynamic>> sessions,
    required String studentKey,
    required int attended,
    required double percentage,
  }) {
    final name = student['name']?.toString() ?? '';
    final sid = student['studentId']?.toString() ?? '';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          _cell('$sl', width: _columnWidth('SL')),
          _cell(sid, width: _columnWidth('ID')),
          _cell(name, width: _columnWidth('Name'), alignLeft: true),
          ...List<Widget>.generate(sessions.length, (i) {
            final records = sessions[i]['records'] as Map<String, dynamic>;
            final raw = records[studentKey]?.toString() ?? '-';
            final short = raw == 'Present' ? 'P' : (raw == 'Absent' ? 'A' : '-');
            Color color;
            if (short == 'P') {
              color = Colors.green;
            } else if (short == 'A') {
              color = Colors.red;
            } else {
              color = Colors.grey;
            }
            return _cell(
              short,
              width: _columnWidth('C1'),
              color: color,
              fontWeight: FontWeight.w700,
            );
          }),
          _cell('$attended', width: _columnWidth('Att'), fontWeight: FontWeight.w700),
          _cell(
            '${percentage.toStringAsFixed(1)}%',
            width: _columnWidth('Att %'),
            color: percentage >= 75
                ? Colors.green
                : (percentage >= 50 ? Colors.orange : Colors.red),
            fontWeight: FontWeight.w700,
          ),
        ],
      ),
    );
  }

  Widget _tag(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cell(
    String text, {
    required double width,
    bool isHeader = false,
    bool alignLeft = false,
    Color? color,
    FontWeight? fontWeight,
  }) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignLeft ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: color ?? Colors.black87,
            fontWeight: isHeader ? FontWeight.w700 : (fontWeight ?? FontWeight.w500),
          ),
        ),
      ),
    );
  }

  double _columnWidth(String header) {
    if (header == 'SL') return 44;
    if (header == 'ID') return 88;
    if (header == 'Name') return 170;
    if (header == 'Att') return 56;
    if (header == 'Att %') return 72;
    return 48;
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }
}
