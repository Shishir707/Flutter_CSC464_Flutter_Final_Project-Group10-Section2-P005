import 'dart:ffi';

import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, '📅 Class Routine'),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("courses")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return CircularProgressIndicator();
                    }

                    final courses = snapshot.data!.docs;

                    return DropdownButtonFormField<String>(
                      hint: Text("Select Course"),
                      initialValue: selectedCourseId,
                      items: courses.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text(c["code"]),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedCourseId = value;
                        });
                      },
                    );
                  },
                ),

                SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  hint: const Text("Select Day"),
                  initialValue: selectedDay,
                  items: const [
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
                  hint: const Text("Select Time Slot"),
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
                    DropdownMenuItem(
                      value: "14:40-16:10",
                      child: Text("14:40 - 16:10"),
                    ),
                    DropdownMenuItem(
                      value: "16:20-17:50",
                      child: Text("16:20 - 17:50"),
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
                    child: Text(
                      "Add Routine",
                      style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("routine")
                  .snapshots(),
              builder: (context, routineSnapshot) {
                if (!routineSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("courses")
                      .snapshots(),
                  builder: (context, courseSnapshot) {
                    if (!courseSnapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final routines = routineSnapshot.data!.docs;
                    final courses = courseSnapshot.data!.docs;

                    final courseMap = {for (var c in courses) c.id: c["code"]};

                    Map<String, List<Map<String, dynamic>>> grouped = {};

                    for (var doc in routines) {
                      final data = doc.data() as Map<String, dynamic>;
                      final day = data["day"];

                      grouped.putIfAbsent(day, () => []);
                      grouped[day]!.add(data);
                    }

                    if (grouped.isEmpty) {
                      return const Center(child: Text("No routine added"));
                    }

                    return ListView(
                      children: grouped.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10),
                              child: Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            ...entry.value.map((r) {
                              final title =
                                  courseMap[r["courseId"]] ?? "Unknown";

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 5,
                                ),
                                child: ListTile(
                                  title: Text(title),
                                  subtitle: Text("⏰ ${r["time"]}"),
                                ),
                              );
                            }),
                          ],
                        );
                      }).toList(),
                    );
                  },
                );
              },
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

    try {
      final existing = await FirebaseFirestore.instance
          .collection("routine")
          .where("courseId", isEqualTo: selectedCourseId)
          .where("day", isEqualTo: selectedDay)
          .where("time", isEqualTo: selectedTime)
          .get();

      if (!mounted) return;

      if (existing.docs.isNotEmpty) {
        falseScaffoldMessage(context, "Routine already exists ❌");
        return;
      }

      await FirebaseFirestore.instance.collection("routine").add({
        "courseId": selectedCourseId,
        "day": selectedDay,
        "time": selectedTime,
        "createdAt": Timestamp.now(),
      });

      setState(() {
        selectedCourseId = null;
        selectedDay = null;
        selectedTime = null;
      });

      if (!mounted) return;

      trueScaffoldMessage(context, "Routine added ✅");
    } catch (e) {
      falseScaffoldMessage(context, "e.toString()");
    }
  }
}
