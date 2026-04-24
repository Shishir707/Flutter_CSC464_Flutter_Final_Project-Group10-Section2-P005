import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/UI/Widget/scaffold_message.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Provider/course_provider.dart';
import '../Data/Modals/course_modal.dart';
import '../Widget/edit_dialog.dart';

class CourseScreen extends StatefulWidget {
  const CourseScreen({super.key});

  @override
  State<CourseScreen> createState() => _CourseScreenState();
}

class _CourseScreenState extends State<CourseScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<CourseProvider>(context, listen: false).loadCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "📚 All Courses"),

      body: Consumer<CourseProvider>(
        builder: (context, provider, child) {
          if (provider.courses.isEmpty) {
            return Center(child: Text("No courses found"));
          }

          return ListView.builder(
            padding: EdgeInsets.all(12),
            itemCount: provider.courses.length,
            itemBuilder: (context, index) {
              final course = provider.courses[index];

              return Container(
                margin: EdgeInsets.only(bottom: 14),
                padding: EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            course.name,
                            style: TextStyle(
                              color: Colors.black87,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        IconButton(
                          onPressed: () => _onTapDeleteButton(course.id!),
                          icon: Icon(Icons.delete, color: Colors.red[200]),
                        ),

                        IconButton(
                          onPressed: () => _onTapEditButton(course),
                          icon: Icon(Icons.edit, color: Colors.white),
                        ),
                      ],
                    ),

                    SizedBox(height: 6),

                    Text(
                      " • ${course.code}",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        backgroundColor: Colors.blue[300],
        child: Icon(Icons.add),
      ),
    );
  }

  void _onTapDeleteButton(String id) async {
    await Provider.of<CourseProvider>(context, listen: false).deleteCourse(id);

    if (!mounted) return;

    trueScaffoldMessage(context, "Deleted Successfully");
  }

  void _addCourse() {
    Navigator.pushNamed(context, '/add-course');
  }

  void _onTapEditButton(Course course) {
    showDialog(
      context: context,
      builder: (_) => EditCourseDialog(course: course),
    );
  }
}
