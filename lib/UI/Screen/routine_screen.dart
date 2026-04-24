import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Provider/course_provider.dart';
import '../../Provider/routine_provider.dart';
import '../Data/Modals/routine_model.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  String? selectedCourseId;
  String? selectedDay;
  String? selectedTime;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (!mounted) return;
      Provider.of<RoutineProvider>(context, listen: false).loadRoutines();
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseProvider = Provider.of<CourseProvider>(context);
    final routineProvider = Provider.of<RoutineProvider>(context);

    final courses = courseProvider.courses;
    final routines = routineProvider.routines;

    final courseMap = {for (var course in courses) course.id: course.code};

    Map<String, List<Routine>> grouped = {};

    for (var routine in routines) {
      grouped.putIfAbsent(routine.day, () => []);
      grouped[routine.day]!.add(routine);
    }

    return Scaffold(
      appBar: mainAppBar(context, '📅 Class Routine'),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  hint: Text("Select Course"),
                  initialValue: selectedCourseId,
                  items: courses.map((c) {
                    return DropdownMenuItem(value: c.id, child: Text(c.code));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedCourseId = value;
                    });
                  },
                ),

                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  hint: Text("Select Day"),
                  initialValue: selectedDay,
                  items: [
                    DropdownMenuItem(value: "ST", child: Text("ST")),
                    DropdownMenuItem(value: "MW", child: Text("MW")),
                    DropdownMenuItem(value: "AR", child: Text("AR")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedDay = value;
                    });
                  },
                ),

                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  hint: Text("Select Time Slot"),
                  initialValue: selectedTime,
                  items: [
                    DropdownMenuItem(
                      value: "08:00-09:30",
                      child: Text("08:00 - 09:30"),
                    ),
                    DropdownMenuItem(
                      value: "09:40-11:10",
                      child: Text("09:40 - 11:10"),
                    ),
                    DropdownMenuItem(
                      value: "11:20-12:50",
                      child: Text("11:20 - 12:50"),
                    ),
                    DropdownMenuItem(
                      value: "13:00-14:30",
                      child: Text("13:00 - 14:30"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTime = value;
                    });
                  },
                ),

                SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _onTapAddRoutine,
                    child: Text("Add Routine"),
                  ),
                ),
              ],
            ),
          ),

          Divider(),

          Expanded(
            child: grouped.isEmpty
                ? Center(child: Text("No routine added"))
                : ListView(
                    children: grouped.entries.map((entry) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.all(10),
                            child: Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          ...entry.value.map((r) {
                            final courseName =
                                courseMap[r.courseId] ?? "Unknown";

                            return Card(
                              margin: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 5,
                              ),
                              child: ListTile(
                                title: Text(courseName),
                                subtitle: Text("⏰ ${r.time}"),
                              ),
                            );
                          }),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _onTapAddRoutine() async {
    if (selectedCourseId == null ||
        selectedDay == null ||
        selectedTime == null) {
      falseScaffoldMessage(context, "Fill all fields");
      return;
    }

    final routine = Routine(
      courseId: selectedCourseId!,
      day: selectedDay!,
      time: selectedTime!,
    );

    final error = await Provider.of<RoutineProvider>(
      context,
      listen: false,
    ).addRoutine(routine);

    if (!mounted) return;

    if (error != null) {
      falseScaffoldMessage(context, error);
      return;
    }

    trueScaffoldMessage(context, "Routine added ✅");

    setState(() {
      selectedCourseId = null;
      selectedDay = null;
      selectedTime = null;
    });
  }
}
