// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:video_player/main.dart';
//
// class Splashscreen extends StatefulWidget {
//   const Splashscreen({super.key});
//
//   @override
//   State<Splashscreen> createState() => _SplashscreenState();
// }
//
// class _SplashscreenState extends State<Splashscreen> {
//
//   @override
//   void initState() {
//     super.initState();
//
//     Timer(
//         const Duration(seconds: 5),
//             () {
//           Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(
//                   builder: (context) => const MyHomePage()
//               )
//           );
//         }
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(
//       body: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               Image(
//                 image: AssetImage('./assets/logo.png'),
//                 width: 150,
//                 height: 150,
//               ),
//               SizedBox(height: 10),
//               Text(
//                 "VideoPlayFlix",
//                 style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold
//                 ),
//               )
//             ],
//           )
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../main.dart';
import 'permission_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionAndNavigate();
  }

  Future<void> _checkPermissionAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulate loading

    final status = await Permission.manageExternalStorage.status;
    final hasPermission = status.isGranted;

    if (hasPermission) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PermissionPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage('./assets/logo.png'),
              width: 150,
              height: 150,
            ),
            SizedBox(height: 10),
            Text(
              "VideoPlayFlix",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}