import 'package:academix/UI/Card/menu_card.dart';
import 'package:academix/UI/Widget/main_appbar.dart';
import 'package:academix/Utils/asset_path.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: mainAppBar(context, "🎓 Academix"),

      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                height: 500,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: AssetImage(AssetsPath.homeImage),
                  ),
                ),
              ),

              SizedBox(height: 10),

              Text(
                "Welcome to Academix",
                style: Theme.of(context).textTheme.titleLarge,
              ),

              Divider(color: Colors.red),

              SizedBox(height: 20),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1,
                children: [
                  MenuCard(
                    icon: Icons.book,
                    title: "Courses Management",
                    color: Colors.deepPurple,
                    onTap: () {
                      Navigator.pushNamed(context, '/course');
                    },
                  ),
                  MenuCard(
                    icon: Icons.person,
                    title: "Student Enrollment",
                    color: Colors.blue,
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.check_circle,
                    title: "Attendance",
                    color: Colors.green,
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.schedule,
                    title: "Attendance Summary",
                    color: Colors.purpleAccent,
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.calendar_month,
                    title: "Class Routine",
                    color: Colors.pink,
                    onTap: () {},
                  ),
                  MenuCard(
                    icon: Icons.info,
                    title: "About",
                    color: Colors.greenAccent,
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
  }
}
