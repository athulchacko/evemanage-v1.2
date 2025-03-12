import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:miniproj/pages/CreateEventScreen.dart';
import 'package:miniproj/pages/ForgotPasswordPage%20.dart';
import 'package:miniproj/pages/HomeScreen1.dart';
import 'package:miniproj/pages/LoginApp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyCBX8t2XwePM6CIR50cWn3VLC-Ftu9qZlY",
        authDomain: "evemanage-37959.firebaseapp.com",
        projectId: "evemanage-37959",
        storageBucket: "evemanage-37959.firebasestorage.app",
        messagingSenderId: "863293804008",
        appId: "1:863293804008:web:3673d7bb5c046941bd285d",
        measurementId: "G-G4CJ435H2W"),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Event Management System',
      initialRoute: '/login', // Set the initial route to the login page
      routes: {
        '/': (context) => HomeScreen1(),
        '/login': (context) => LoginPage(), // Define the login route
        '/create-event': (context) => CreateEventScreen(),
        '/forgot-password': (context) => ForgotPasswordPage(),
        // Add other routes here
      },
    );
  }
}
