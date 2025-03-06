import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miniproj/pages/HomeScreen1.dart';
import 'package:miniproj/pages/LoginApp.dart';


class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // if (snapshot.connectionState == ConnectionState.waiting) {
          //   // While the connection is still loading, you can return a loading indicator
          //   return const Center(child: CircularProgressIndicator());
          // }

          // to check if the user is logged in
          if (snapshot.hasData) {
            return  HomeScreen1(); 
          } else {
            var loginPage = LoginPage();
            return  loginPage;  
          }
        },
      ),
    );
  }
}