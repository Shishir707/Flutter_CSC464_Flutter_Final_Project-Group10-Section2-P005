import 'package:academix/UI/Controller/firebase_controller.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  final AcademixController _controller = AcademixController();
  String? _selectedCourseId;
  String _searchText = '';
  final Map<String, String> _records = <String, String>{};
  bool _isSaving = false;
  bool _isFetchingSaved = false;
  bool _submittedToday = false;

  DateTime get _today => DateTime.now();

  DateTime get _normalizedDate => DateTime(_today.year, _today.month, _today.day);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: mainAppBar(context, 'Attendance'),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 10),
              _buildSearchBox(),
              const SizedBox(height: 10),
              const TabBar(
                tabs: [
                  Tab(text: 'Mark Sheet'),
                  Tab(text: 'History'),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _selectedCourseId == null
                    ? _buildEmptyState('Select a course to continue')
                    : TabBarView(
                        children: [
                          _buildMarkingSheet(),
                          _buildAttendanceHistory(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          child: Column(
            children: [
              DropdownButtonFormField<String>(
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
                          '${course['name'] ?? ''} (${course['code'] ?? ''})',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) async {
                  if (value == _selectedCourseId) {
                    return;
                  }
                  setState(() {
                    _selectedCourseId = value;
                    _records.clear();
                  });
                  await _fetchExistingAttendance();
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(Icons.today_rounded, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    'Date: ${_formatDate(_today)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Today Only',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
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

  Widget _buildMarkingSheet() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _controller.streamStudents(_selectedCourseId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isFetchingSaved) {
          return const Center(child: CircularProgressIndicator());
        }

        final students = snapshot.data ?? <Map<String, dynamic>>[];

        if (students.isEmpty) {
          return _buildEmptyState('No students enrolled in this course');
        }

        for (final student in students) {
          final key = _studentKey(student);
          if (key.isNotEmpty) {
            _records.putIfAbsent(key, () => 'Absent');
          }
        }

        final filtered = students.where((student) {
          if (_searchText.isEmpty) {
            return true;
          }
          final name = (student['name']?.toString() ?? '').toLowerCase();
          final studentId = (student['studentId']?.toString() ?? '').toLowerCase();
          return name.contains(_searchText) || studentId.contains(_searchText);
        }).toList();

        if (filtered.isEmpty) {
          return _buildEmptyState('No student found for search');
        }

        final present = filtered
            .where((s) => _records[_studentKey(s)] == 'Present')
            .length;
        final absent = filtered.length - present;
        final ratio = filtered.isEmpty ? 0.0 : (present / filtered.length) * 100;

        return Column(
          children: [
            _buildTopStats(total: filtered.length, present: present, absent: absent, ratio: ratio),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _submittedToday ? null : () => _setAllStatus(filtered, 'Present'),
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Mark All Present'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _submittedToday ? null : () => _setAllStatus(filtered, 'Absent'),
                    icon: const Icon(Icons.highlight_off),
                    label: const Text('Mark All Absent'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_submittedToday)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: const Text(
                  'Attendance already submitted for today. Editing is locked.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            Expanded(child: _buildTable(filtered)),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: (_isSaving || _submittedToday) ? null : _saveAttendance,
                icon: _isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_alt_rounded),
                label: Text(
                  _isSaving
                      ? 'Saving...'
                      : 'Submit Attendance (${_formatDate(_today)})',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopStats({
    required int total,
    required int present,
    required int absent,
    required double ratio,
  }) {
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
          _tag('Students', '$total', Colors.blue),
          const SizedBox(width: 8),
          _tag('Present', '$present', Colors.green),
          const SizedBox(width: 8),
          _tag('Absent', '$absent', Colors.red),
          const SizedBox(width: 8),
          _tag('Ratio', '${ratio.toStringAsFixed(1)}%', Colors.indigo),
        ],
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> students) {
    const headers = <String>['SL', 'ID', 'Name', 'Today', 'Action'];
    const tableWidth = 620.0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: tableWidth,
          child: Column(
            children: [
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: headers
                      .map((h) => _cell(h, width: _width(h), isHeader: true, alignLeft: h == 'Name'))
                      .toList(),
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, __) => Divider(height: 1, color: Colors.blue.shade50),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final key = _studentKey(student);
                    final status = _records[key] ?? 'Absent';
                    final short = status == 'Present' ? 'P' : 'A';
                    final color = short == 'P' ? Colors.green : Colors.red;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          _cell('${index + 1}', width: _width('SL')),
                          _cell(student['studentId']?.toString() ?? '', width: _width('ID')),
                          _cell(
                            student['name']?.toString() ?? '',
                            width: _width('Name'),
                            alignLeft: true,
                          ),
                          _cell(
                            short,
                            width: _width('Today'),
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                          SizedBox(
                            width: _width('Action'),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ChoiceChip(
                                  label: const Text('Present'),
                                  selected: status == 'Present',
                                  selectedColor: Colors.green,
                                  labelStyle: TextStyle(
                                    color: status == 'Present' ? Colors.white : Colors.green,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: _submittedToday
                                      ? null
                                      : (_) {
                                          setState(() {
                                            _records[key] = 'Present';
                                          });
                                        },
                                ),
                                const SizedBox(width: 6),
                                ChoiceChip(
                                  label: const Text('Absent'),
                                  selected: status == 'Absent',
                                  selectedColor: Colors.red,
                                  labelStyle: TextStyle(
                                    color: status == 'Absent' ? Colors.white : Colors.red,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  onSelected: _submittedToday
                                      ? null
                                      : (_) {
                                          setState(() {
                                            _records[key] = 'Absent';
                                          });
                                        },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildAttendanceHistory() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('attendance')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? <QueryDocumentSnapshot<Map<String, dynamic>>>[];

        if (docs.isEmpty) {
          return _buildEmptyState('No attendance history yet');
        }

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final item = docs[index].data();
            final date = (item['date'] as Timestamp?)?.toDate();
            final records = Map<String, dynamic>.from(
              item['records'] as Map<String, dynamic>? ?? <String, dynamic>{},
            );
            final present = records.values.where((s) => s == 'Present').length;
            final total = records.length;
            final ratio = total == 0 ? 0.0 : (present / total) * 100;

            return Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: const Icon(Icons.event_available, color: Colors.blue),
                ),
                title: Text(date == null ? 'Unknown Date' : _formatDate(date)),
                subtitle: Text('Present: $present / $total   (${ratio.toStringAsFixed(1)}%)'),
                trailing: TextButton(
                  onPressed: () => _showHistoryDetails(records),
                  child: const Text('Details'),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _fetchExistingAttendance() async {
    if (_selectedCourseId == null) {
      return;
    }

    setState(() {
      _isFetchingSaved = true;
      _submittedToday = false;
    });

    try {
      final data = await FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('attendance')
          .where('date', isEqualTo: Timestamp.fromDate(_normalizedDate))
          .limit(1)
          .get();

      final doc = data.docs.isEmpty ? null : data.docs.first.data();
      final existingRecords = Map<String, dynamic>.from(
        doc?['records'] as Map<String, dynamic>? ?? <String, dynamic>{},
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _submittedToday = data.docs.isNotEmpty;
        for (final entry in existingRecords.entries) {
          _records[entry.key] = entry.value.toString();
        }
      });
    } catch (_) {
      if (mounted) {
        falseScaffoldMessage(context, 'Could not load attendance for selected date');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingSaved = false;
        });
      }
    }
  }

  Future<void> _saveAttendance() async {
    if (_selectedCourseId == null) {
      falseScaffoldMessage(context, 'Please select a course');
      return;
    }

    if (_submittedToday) {
      falseScaffoldMessage(context, 'Attendance already submitted for today');
      return;
    }

    if (_records.isEmpty) {
      falseScaffoldMessage(context, 'No students found to mark attendance');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final collection = FirebaseFirestore.instance
          .collection('courses')
          .doc(_selectedCourseId)
          .collection('attendance');

      final existing = await collection
          .where('date', isEqualTo: Timestamp.fromDate(_normalizedDate))
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        if (mounted) {
          setState(() {
            _submittedToday = true;
          });
          falseScaffoldMessage(context, 'Attendance already submitted for today');
        }
        return;
      }

      final payload = <String, dynamic>{
        'date': Timestamp.fromDate(_normalizedDate),
        'records': _records,
      };

      await collection.add(payload);

      if (!mounted) {
        return;
      }

      trueScaffoldMessage(context, 'Attendance saved successfully');
      setState(() {
        _submittedToday = true;
      });
    } catch (_) {
      if (mounted) {
        falseScaffoldMessage(context, 'Failed to save attendance');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _setAllStatus(List<Map<String, dynamic>> students, String status) {
    setState(() {
      for (final student in students) {
        final key = _studentKey(student);
        if (key.isNotEmpty) {
          _records[key] = status;
        }
      }
    });
  }


  void _showHistoryDetails(Map<String, dynamic> records) {
    showDialog<void>(
      context: context,
      builder: (context) {
        final ids = records.keys.toList();

        return AlertDialog(
          title: const Text('Attendance Details'),
          content: SizedBox(
            width: 320,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: ids.length,
              itemBuilder: (context, index) {
                final studentId = ids[index];
                final status = records[studentId]?.toString() ?? 'Absent';
                return ListTile(
                  dense: true,
                  title: Text(studentId),
                  trailing: Text(
                    status,
                    style: TextStyle(
                      color: status == 'Present' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _tag(String label, String value, Color color) {
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
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
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

  double _width(String header) {
    if (header == 'SL') return 44;
    if (header == 'ID') return 90;
    if (header == 'Name') return 210;
    if (header == 'Today') return 56;
    if (header == 'Action') return 160;
    return 60;
  }

  Widget _buildEmptyState(String text) {
    return Center(
      child: Text(
        text,
        style: TextStyle(color: Colors.grey.shade700),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }

  String _studentKey(Map<String, dynamic> student) {
    final id = student['id']?.toString() ?? '';
    if (id.isNotEmpty) {
      return id;
    }
    return student['studentId']?.toString() ?? '';
  }
}
