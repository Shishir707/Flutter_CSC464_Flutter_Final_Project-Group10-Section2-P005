import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("🎓 Academix"),
        centerTitle: true,

        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: "Logout",
            color: Colors.red,
            onPressed: () => _logout(context),
          ),
        ],
      ),

      body: const Center(child: Text("Home Screen")),
    );
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.pushNamedAndRemoveUntil(context, '/sign-in', (route) => false);
  }
}
