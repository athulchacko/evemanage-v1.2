import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:miniproj/pages/wrapper.dart';

class splashscreen extends StatefulWidget {
  const splashscreen({super.key});

  @override
  State<splashscreen> createState() => _splashscreenState();
}

class _splashscreenState extends State<splashscreen>  with SingleTickerProviderStateMixin {
  @override

  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);

    Future.delayed(const Duration(seconds: 2), () {
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => Wrapper(),
        ),
      );
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       
       body: SingleChildScrollView(
         child: Column(
          children: [
            
            const SizedBox(height: 250),
            Image.asset("assets/wordwise.png"),
          ],
         ),
       ),
    );
  }
}