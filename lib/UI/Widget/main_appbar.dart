import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget mainAppBar(BuildContext context, String title) {
  return AppBar(
    title: Text(title),
    centerTitle: true,
    actions: [
      IconButton(
        icon: Icon(Icons.logout),
        tooltip: "Logout",
        color: Colors.red,
        onPressed: () async {
          await FirebaseAuth.instance.signOut();

          Navigator.pushNamedAndRemoveUntil(
            context,
            '/sign-in',
            (route) => false,
          );
        },
      ),
    ],
  );
}
