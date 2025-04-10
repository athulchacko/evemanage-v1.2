import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:miniproj/pages/AdminDashboardScreen.dart';
import 'package:miniproj/pages/HomeScreen1.dart';
import 'package:miniproj/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false; // State variable for password visibility

  // Login Function with Improved Error Handling
  Future<void> loginUser(
      BuildContext context,
      TextEditingController emailController,
      TextEditingController passwordController) async {
    FirebaseAuth _auth = FirebaseAuth.instance;
    FirebaseFirestore _firestore = FirebaseFirestore.instance;

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      // Get the logged-in user's UID
      String uid = userCredential.user!.uid;
      print("✅ User logged in with UID: $uid");

      // Fetch user role from Firestore
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();

      if (userDoc.exists) {
        String role = userDoc.get("role");
        print("✅ User role: $role");

        // Fetch additional user details
        await fetchUserDetails();

        // Navigate based on role
        if (role == "admin") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) =>  AdminDashboard()),
          );
        } else if (role == "user") {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen1()),
          );
        } else {
          print("⚠️ Unknown role: $role");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Unknown user role")),
          );
        }
      } else {
        print("⚠️ User document does not exist in Firestore!");
        throw Exception("User role not found!");
      }
    } on FirebaseAuthException catch (e) {
      print("🔥 FirebaseAuthException: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login failed: ${e.message}")),
      );
    } catch (e) {
      print("🔥 Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("⚠️ No user signed in!");
      return;
    }

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection("users")
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        print("✅ User Data: ${userDoc.data()}");
      } else {
        print("⚠️ User document does not exist in Firestore!");
      }
    } catch (e) {
      print("🔥 Error fetching user details: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "EVE MANAGE",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 5),
                const Text(
                  "ONE APP, ENDLESS POSSIBILITIES",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 30),

                // Email Input
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email_outlined),
                    hintText: "Enter Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 15),

                // Password Input
                TextField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                    hintText: "Enter Password",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to Forgot Password Page
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text(
                      "Forgot password?",
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () => loginUser(
                            context, emailController, passwordController),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Login",
                            style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 15),

                // Divider
                const Text("Or", style: TextStyle(color: Colors.grey)),

                const SizedBox(height: 15),

                // Signup Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account?"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignUpPage()),
                        );
                      },
                      child: const Text("Signup",
                          style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
